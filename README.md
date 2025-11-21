🏌️Divot

Divot is a mobile golf-course review application built with:

Swift (iOS) for the frontend

A Flask backend that handles authentication, course data, reviews, and other API logic

A lightweight Dockerized backend environment for portability and deployment

Divot’s backend exposes REST endpoints consumed by the mobile app, and is designed to be simple, fast, and easy to deploy while the project is still in active development.

--- 

☁️ What This Repository Contains

This repository provides the Terraform infrastructure code required to deploy the Divot backend on AWS.

The deployment uses a clean module-based structure, and provisions:

An EC2 instance that runs the Dockerized Flask backend

A security group allowing HTTP traffic

User data to install Docker and launch the application container at boot

All AWS resources needed for a functional, public endpoint the mobile app can call

Terraform manages all provisioning, updates, and teardown to keep deployments reproducible and version-controlled.

--- 
