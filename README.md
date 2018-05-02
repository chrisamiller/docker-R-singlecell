# docker-single-cell
Basic docker image for single-cell analyses - combines a lot of the tools that are handy for exploring data on a ubuntu base image.

### Notes:
- R 3.5 and some basic packages are installed (Seurat, DropletUtils). For convenience, it can be useful to set up a specific folder in which to keep your own library installs for testing. This will keep them persistent across sessions. Add something like this to your .Rprofile:
    ```
    devlib <- paste('/gscuser/cmiller/usr/lib/R',paste(R.version$major,R.version$minor,sep="."),sep="")
    if (!file.exists(devlib))
    dir.create(devlib)
    x <- .libPaths()
    .libPaths(c(devlib,x))
    rm(x,devlib)```
    
This is great for quickly prototyping, but don't forget that if you're sharing code with others, you'll need to create a new container with the proper libraries installed so they can also use it!
