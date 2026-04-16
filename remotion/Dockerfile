FROM node:20-slim
RUN apt-get update && apt-get install -y chromium fonts-liberation fonts-noto-color-emoji && rm -rf /var/lib/apt/lists/*
ENV REMOTION_CHROME_EXECUTABLE=/usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
WORKDIR /app
COPY package*.json ./
RUN npm ci --production 2>/dev/null || npm init -y && npm install @remotion/cli @remotion/renderer remotion react react-dom
COPY . .
EXPOSE 3000
CMD ["npx", "remotion", "studio", "--port", "3000"]
