# first, we need to actually build a release to run in our container
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
# the FROM word lets us use a base image, in this instance, dotnet 8.0 (or whatever version your
# project is in)

#we have to specify a directory to work in
WORKDIR /App

#Copies everything from the current project directory (your C# files) into WORKDIR specified above
COPY ../ ./

WORKDIR /App/lab5connorcole
# restores project dependencies, using NuGet to look for and download them if necessary
RUN dotnet restore
# build + publish a release into the /out folder (it's in /App/out, as /App is our working directory)
RUN dotnet publish -o out


# we have to kind of start again, this time to actually run it.
# previous steps built and published our project, giving us some files that let it run standalone
# now we need to create the part that actually runs the project
FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /App/lab5connorcole
EXPOSE 8080
# copies the published build contents into our /App directory,
# allowing us to work with those files (and our app, now executable)
COPY --from=build /App/lab5connorcole/out . 
#replace 2nd parameter with whatever your project name is!
# i.e., whatever is in front of your .csproj file
ENTRYPOINT ["dotnet", "lab5connorcole.dll"] 
# above, the entrypoint tells docker what to run when it starts
# this one sets dotnet as the host for our dll (dynamic-linked library)

# to build, you'll need to run
# docker build -t image-name -f Dockerfile . 
# DON'T FORGET THE PERIOD!!!
# this creates a local repository named.. whatever you enter 
# -f points to the Dockerfile (replace with your path, if different)

# to start a blazor app in docker, run 
# docker run -p 8080:80 --name container-name image-name

#to show logs, do 
# docker logs -f image-name (or --follow)

# to stop a contaner:
# docker stop <container name/id>

# to run a stopped container, 
# docker start <container name/id>
