# -----Base Node-----
FROM node:20.9.0 AS base
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install -g @angular/cli
RUN npm install
COPY . . 

# -----Test-----
FROM base AS test
# Installing Playwright
RUN npx playwright install   
RUN npx playwright install-deps   
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* 
COPY tests/ /app/tests/
EXPOSE 9323:9323
RUN npx playwright test
CMD [ "npx","playwright","show-report" ]

# -----Build-----
FROM base AS build
RUN npm run build


# -----release-----
FROM node:20.10.0-slim AS release
COPY --from=build /usr/src/app/dist ./dist
EXPOSE 4200
CMD ["npm", "start"]