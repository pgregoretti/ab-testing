# Edge A/B Testing with Varnish

This repo demonstrates a simple **A/B testing system implemented at the edge** using Varnish Configuration Language. Traffic is split between two backend services (A and B), with user assignment persisted via cookies.

---

## Project Structure

```
.
├── docker-compose.yml
├── default.vcl
├── backend-a/
│   └── index.html
├── backend-b/
│   └── index.html
└── README.md
```


## Tech Stack

- Varnish Cache (VCL)
- Docker
- Nginx (as backend services)
- Docker Compose

### 1. Request Flow

1. Client sends request to Varnish
2. Varnish checks for `experiment` cookie
3. If present → user is routed consistently
4. If absent → user is randomly assigned:
   - ~40% → Backend B
   - ~60% → Backend A
5. Assignment is stored in a cookie
6. Response includes debug headers for visibility

### 2. Example Headers

```http
HTTP/1.1 200 OK
X-Experiment: A
X-Backend: backend_a
Set-Cookie: experiment=A; Path=/
```

## 🧪 Running the Project
1. Start services
```docker compose up --build```
2. Test basic routing
```curl -I http://localhost:8080```
3. Test A/B consistency
```curl -I --cookie "experiment=B" http://localhost:8080```

Expected output:

```http
HTTP/1.1 200 OK
X-Experiment: B
X-Backend: backend_b
```

This can also be done by visiting ```http://localhost:8080``` in the browser and visiting the respective ```index.html``` page.
