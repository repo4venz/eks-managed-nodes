Install Ollama:
Open your terminal and install Ollama using the provided command: curl -fsSL https://ollama.com/install.sh | sh. 
This script will download and install Ollama, and it will attempt to detect and utilize your Nvidia GPU if available for faster processing. 

https://github.com/awslabs/mcp/tree/main/src/eks-mcp-server

ollama run llama3.1

ollama list
ollama run <model_name>


ollama serve &

sudo systemctl status ollama
sudo systemctl stop ollama


https://github.com/ollama/ollama


https://pypi.org/project/awslabs.cost-explorer-mcp-server/

docker build -t ollama-llama3.1-8b -f dockerfile-ollama-llama3.1-8b .

docker tag ollama-llama3.1-8b:latest dockersuvendu/ollama-llama3.1-8b:latest
docker rmi dockerhub.com/dockersuvendu/ollama-llama3.1-8b:latest

docker push dockersuvendu/ollama-llama3.1-8b:latest

docker ps

 docker exec ollama curl -s http://localhost:11434/api/chat
 


# Stage 1: Download the model
FROM ollama/ollama:latest AS builder

# Start Ollama server and pull model in one layer
RUN (ollama serve &) && \
    sleep 15 && \
    ollama pull llama3.1 && \
    pkill ollama

# Stage 2: Create final image
FROM ollama/ollama:latest

# Copy the downloaded model
COPY --from=builder /root/.ollama /root/.ollama

EXPOSE 11434
CMD ["sh", "-c", "sleep 5 && ollama serve"]




FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://ollama.com/install.sh | sh

RUN mkdir -p /root/.ollama && \
    chmod -R 777 /root/.ollama

#RUN ollama pull llama3

# Start Ollama server and pull model in one layer
RUN (ollama serve &) && \
    sleep 15 && \
    ollama pull llama3.1  

EXPOSE 11434
HEALTHCHECK --interval=30s --timeout=5s \
  CMD curl -f http://localhost:11434 || exit 1

CMD ["sh", "-c", "sleep 5 && ollama serve"]


docker exec ollama curl -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.1",
    "messages": [
      {
        "role": "user",
        "content": "Hello! How are you?"
      }
    ]
  }'
  
  docker exec ollama curl -X POST http://localhost:11434/api/generate -d '{"model":"llama3.1","prompt":"test"}'