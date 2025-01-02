# Use the official ASP.NET image as the base image for the final container
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Use the official .NET SDK image for the build process
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy the project file and restore dependencies
COPY TestService.csproj ./
RUN dotnet restore "TestService.csproj"

# Copy the rest of the source code and build the application
COPY . . 
RUN dotnet build "TestService.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the application in the 'publish' stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "TestService.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final stage: copy the published files to the base image and define entry point
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Set the entry point to start the application
ENTRYPOINT ["dotnet", "TestService.dll"]
