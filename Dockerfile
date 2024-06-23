#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80 443


FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["k8s.api.csproj", "."]
RUN dotnet restore "./k8s.api.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "k8s.api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "k8s.api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV ASPNETCORE_URLS=http://*:80;https://*:443
ASPNETCORE_Kestrel__Certificates__Default__Password=S3cr#tPass
ASPNETCORE_Kestrel__Certificates__Default__Path=/https/aspnetapp.pfx
    volumes:
      - ~/.aspnet/https:/https:ro
ENTRYPOINT ["dotnet", "k8s.api.dll"]