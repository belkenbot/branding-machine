FROM node:20-slim
RUN apt-get update && apt-get install -y ffmpeg curl python3 python3-pip && rm -rf /var/lib/apt/lists/*
RUN pip3 install edge-tts --break-system-packages
WORKDIR /app
COPY package*.json ./
RUN npm ci --production 2>/dev/null || npm init -y
COPY . .
EXPOSE 8200
CMD ["node", "server.js"]
