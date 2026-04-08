# first, we need to actually build a release to run in our container
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS build
# the FROM word lets us use a base image, in this instance, dotnet 8.0 (or whatever version your
# project is in)

#we have to specify a directory to work in
WORKDIR /App 

#Copies everything from the current project directory (your C# files) into WORKDIR specified above
COPY . ./
# restores project dependencies, using NuGet to look for and download them if necessary
RUN dotnet restore
# build + publish a release into the /out folder (it's in /App/out, as /App is our working directory)
RUN dotnet publish -o out

# we have to kind of start again, this time to actually run it.
# previous steps built and published our project, giving us some files that let it run standalone
# now we need to create the part that actually runs the project
FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /App
# copies the published build contents into our /App directory,
# allowing us to work with those files (and our app, now executable)
COPY --from=build /App/out . 
#replace 2nd parameter with whatever your project name is!
# i.e., whatever is in front of your .csproj file
ENTRYPOINT ["dotnet", "lab5connorcole.dll"] 
# above, the entrypoint tells docker what to run when it starts
# this one sets dotnet as the host for our dll (dynamic-linked library)
