FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

# Install Node.js and npm
RUN apt-get update \
    && apt-get install -y curl ca-certificates gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && node --version \
    && npm --version \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN dotnet restore SummitCorporate.csproj

RUN npm ci

RUN dotnet publish SummitCorporate.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0

WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080

EXPOSE 8080

ENTRYPOINT ["dotnet", "SummitCorporate.dll"]