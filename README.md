# Vibe IDE DA (Static + Code Engine Broker)

Developer‑friendly, IBM Plex–powered Vibe IDE with gradient vibes. One‑click “Push to Cloud” publishes your edited `index.html` into a public COS bucket via a secure, rate‑limited broker running on IBM Cloud Code Engine.

## What’s inside
- **/www** – static Vibe IDE (IBM Plex Sans/Serif)
- **/broker** – Node.js broker (Express, rate‑limited, App ID JWT verification, COS write)
- **/terraform** – IaC for COS, bucket objects, App ID, IAM policy, Code Engine project/app/secret

## Prereqs
- Terraform >= 1.5
- IBM Cloud account (free plan is fine)
- A container image for the broker (build & push first)

```bash
# Build & push broker image
cd broker
docker build -t <your_dockerhub>/vibe-broker:latest .
docker push <your_dockerhub>/vibe-broker:latest
```

## Deploy
```bash
cd terraform
terraform init
terraform apply -auto-approve -var="broker_image=<your_dockerhub>/vibe-broker:latest"
```

Outputs:
- `vibe_ide_url` – open this to use the IDE
- `broker_publish_url` – backend endpoint the IDE calls

## Notes
- Authentication is enforced in the broker via App ID JWT validation (no Code Engine binding required).
- COS “Public Access Group → Object Reader” may still be required in IAM for public reads (set once in GUI if needed).
