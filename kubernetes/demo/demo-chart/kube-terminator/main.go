package main

import (
	"context"
	"flag"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	corev1 "k8s.io/client-go/kubernetes/typed/core/v1"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"log"
	"math/rand/v2"
	"os"
	"os/signal"
	"syscall"
	"time"
)

type terminator struct {
	logger        *log.Logger
	dryRun        bool
	podClient     corev1.PodInterface
	interval      time.Duration
	labelSelector string
}

func main() {
	logger := log.New(os.Stdout, "Startup: ", log.LstdFlags)

	kubeconfigFilename := flag.String("kubeconfig", "", "Path to the kubeconfig file")
	namespace := flag.String("namespace", "", "Namespace of Pods to terminate")
	dryRun := flag.Bool("dry-run", true, "Dry run")
	labelSelector := flag.String("label-selector", "", "Label selector for Pods to terminate, use foo=bar format")
	interval := flag.String("interval", "1m", "Interval between Pod terminations")
	flag.Parse()

	d, err := time.ParseDuration(*interval)
	if err != nil {
		logger.Fatalf("Failed to parse interval: %v", err)
	}

	if *namespace == "" {
		logger.Fatal("Namespace is required")
	}

	var clientSet *kubernetes.Clientset
	if *kubeconfigFilename != "" {
		logger.Printf("Using kubeconfig file: ", *kubeconfigFilename)
		kubeconfigFile, err := os.ReadFile(*kubeconfigFilename)
		if err != nil {
			logger.Fatalf("Failed to read kubeconfig from file: %v", err)
		}
		restConfig, err := clientcmd.RESTConfigFromKubeConfig(kubeconfigFile)
		if err != nil {
			logger.Fatalf("Failed to parse kubeconfig: %v", err)
		}
		clientSet = kubernetes.NewForConfigOrDie(restConfig)
	} else {
		logger.Println("Using in-cluster configuration")
		config, err := rest.InClusterConfig()
		if err != nil {
			logger.Fatalf("Failed to get in-cluster configuration: %v", err)
		}
		clientSet = kubernetes.NewForConfigOrDie(config)
	}

	terminator := terminator{
		logger:        log.New(os.Stdout, "Terminator: ", log.LstdFlags),
		dryRun:        *dryRun,
		labelSelector: *labelSelector,
		interval:      d,
		podClient:     clientSet.CoreV1().Pods(*namespace),
	}

	logger.Printf("Running terminator with interval: %s, dryRun: %t, labelSelector: %s", terminator.interval.String(), terminator.dryRun, terminator.labelSelector)

	ctx := context.Background()
	ctxCancel, cancel := context.WithCancel(ctx)

	go terminator.run(ctxCancel)

	signalWatch := make(chan os.Signal, 1)
	signal.Notify(signalWatch, syscall.SIGTERM, syscall.SIGINT)
	sig := <-signalWatch
	logger.Printf("Received OS signal: %v", sig)
	cancel()
}

func (t *terminator) run(ctx context.Context) {
	listOpt := metav1.ListOptions{}
	if t.labelSelector != "" {
		listOpt.LabelSelector = t.labelSelector
	}
	next := time.Now()
	for {
		select {
		case <-ctx.Done():
			return
		default:
			if time.Now().After(next) {
				pods, err := t.podClient.List(ctx, listOpt)
				if err != nil {
					t.logger.Printf("Failed to list Pods: %v", err)
					next = next.Add(t.interval)
					continue
				}
				if len(pods.Items) == 0 {
					t.logger.Printf("No Pods found with label selector: %s", t.labelSelector)
					t.logger.Printf("I'll be back in %s", t.interval.String())
					next = next.Add(t.interval)
					continue
				}
				deletionCandidate := pods.Items[rand.IntN(len(pods.Items))]
				t.logger.Printf("Deleting Pod: %s", deletionCandidate.Name)
				if !t.dryRun {
					err = t.podClient.Delete(ctx, deletionCandidate.Name, metav1.DeleteOptions{})
					if err != nil {
						t.logger.Printf("Failed to delete Pod: %v", err)
					}
				}
				t.logger.Printf("I'll be back in %s", t.interval.String())
				next = next.Add(t.interval)
			}
		}
	}
}
