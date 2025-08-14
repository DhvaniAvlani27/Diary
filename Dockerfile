# See https://aka.ms/customizecontainer to learn how to customize your debug container 
# and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# ===========================
# 1. Base image (runtime)
# ===========================
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# ===========================
# 2. Build stage
# ===========================
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy project file and restore
COPY ["DiaryApp.csproj", "./"]
RUN dotnet restore "DiaryApp.csproj"

# Copy all source code
COPY . .

# Build project
RUN dotnet build "DiaryApp.csproj" -c $BUILD_CONFIGURATION -o /app/build

# ===========================
# 3. Publish stage
# ===========================
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "DiaryApp.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# ===========================
# 4. Final stage
# ===========================
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DiaryApp.dll"]
