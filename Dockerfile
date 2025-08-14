# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["DiaryApp.csproj", "./"]
RUN dotnet restore

# Copy all source code
COPY . .

# Build and publish
RUN dotnet build --configuration Release --no-restore
RUN dotnet publish --configuration Release --output /app/publish --no-build

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Copy published app
COPY --from=build /app/publish .

# Expose port
EXPOSE 5298

# Set entry point
ENTRYPOINT ["dotnet", "DiaryApp.dll"]
