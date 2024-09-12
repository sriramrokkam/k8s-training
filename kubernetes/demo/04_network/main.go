package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Source IP: %s", r.RemoteAddr)
	log.Printf("Source IP: %s", r.RemoteAddr)
}

func main() {
	http.HandleFunc("/", handler)

	server := &http.Server{
		Addr:                         ":8080",
		Handler:                      nil,
		DisableGeneralOptionsHandler: false,
		TLSConfig:                    nil,
		ReadTimeout:                  10 * time.Second,
		ReadHeaderTimeout:            5 * time.Second,
		WriteTimeout:                 10 * time.Second,
		IdleTimeout:                  10 * time.Second,
		MaxHeaderBytes:               1 << 20,
	}
	log.Fatal(server.ListenAndServe())
}
