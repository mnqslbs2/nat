#' Transform the 3d location of objects such as neurons
#' 
#' \code{xform} is designed to operate on a variety of data types, especially 
#' objects encapsulating neurons.
#' 
#' @details Methods are provided for some specialised S3 classes. Further 
#'   methods can of course be constructed for user-defined S3 classes. However 
#'   this will probalbly not be necessary if the \code{xyzmatrix} and 
#'   \code{`xyzmatrix<-`} generics are suitably overloaded \emph{and} the S3 
#'   object inherits from \code{list}.
#'   
#'   Where reg is a function, it should have a signature like \code{myfun(x,
#'   ...)} where the ... \strong{must} be provided in order to swallow any
#'   arguments passed from higher level functions that are not relevant to this
#'   particular transformation function.
#' @param x an object to transform
#' @param reg an object describing a transformation in any of the forms 
#'   understood by \code{\link{xformpoints}} (see details).
#' @param ... additional arguments passed to methods and eventually to
#'   \code{\link{xformpoints}}
#' @export
#' @rdname xform
#' @seealso \code{\link{xformpoints}}
xform<-function(x, reg, ...) UseMethod('xform')

#' @details TODO get this to work for matrices with more than 3 columns by
#'   working on xyzmatrix definition.
#' @method xform default
#' @export
#' @param na.action How to handle NAs. NB drop may not work for some classes.
#' @rdname xform
xform.default<-function(x, reg, na.action=c('warn','none','drop','error'), ...){
  na.action=match.arg(na.action)
  pointst=xformpoints(reg, x, ...)
  if(na.action=='none') return(pointst)
  naPoints = is.na(pointst[, 1])
  if (any(naPoints)) {
    if (na.action == "drop") 
      pointst = pointst[!naPoints, ]
    else if (na.action == "warn") 
      warning("There were ", length(naPoints), " that could not be transformed")
    else if (na.action == "error") 
      stop("There were ", length(naPoints), " that could not be transformed")
  }
  pointst
}

#' @method xform list
#' @export
#' @rdname xform
#' @param FallBackToAffine Whether to use an affine transform when a cmtk
#'   warping transformation fails.
xform.list<-function(x, reg, FallBackToAffine=TRUE, na.action='error', ...){
  points=xyzmatrix(x)
  pointst=xformpoints(reg, points, FallBackToAffine=FallBackToAffine, 
                na.action=na.action, ...)
  xyzmatrix(x)<-pointst
  x
}

#' @method xform dotprops
#' @export
#' @rdname xform
#' @details the dotprops tangent vectors will be recalculated after the points
#'   have been transformed (even though they could in theory be transformed more
#'   or less correctly).
#' @examples
#' \dontrun{
#' kc1=kcs20[[1]]
#' kc1.default=xform(kc1,function(x,...) x)
#' stopifnot(isTRUE(all.equal(kc1,kc1.default)))
#' kc1.5=xform(kc1,function(x,...) x, k=5)
#' stopifnot(isTRUE(all.equal(kc1.5,kc1.default)))
#' kc1.20=xform(kc1,function(x,...) x, k=20)
#' stopifnot(!isTRUE(all.equal(kc1,kc1.20)))
#' }
xform.dotprops<-function(x, reg, FallBackToAffine=TRUE, ...){
  points=xyzmatrix(x)
  pointst=xform(points, reg=reg, FallBackToAffine=FallBackToAffine, ...)
  xyzmatrix(x)=pointst
  dotprops(x, ...)
}

#' @method xform neuronlist
#' @param subset For \code{xform.neuronlist} indices (character/logical/integer)
#'   that specify a subset of the members of \code{x} to be transformed.
#' @inheritParams nlapply
#' @export
#' @rdname xform
xform.neuronlist<-function(x, reg, subset=NULL, ..., OmitFailures=NA){
  if(length(reg)>1) stop("xform.neuronlist is currently only able to apply",
                         " a single registration to multiple neurons")
  # TODO if x is long there would be some performance benefits in chunking
  # all points from multiple neurons together. I strongly suspect that doing 10
  # at once would approach a 10x speedup.
  nlapply(x, FUN=xform, reg=reg, ..., subset=subset, OmitFailures=OmitFailures)
}

#' Get and assign coordinates for classes containing 3d vertex data
#' 
#' @param x object containing 3d coordinates
#' @param ... additional arguments passed to methods
#' @return Nx3 matrix containing 3d coordinates
#' @export
xyzmatrix<-function(x, ...) UseMethod("xyzmatrix")


#' @method xyzmatrix neuronlist
#' @export
xyzmatrix.neuronlist<-function(x, ...) {
  coords=lapply(x, xyzmatrix, ...)
  do.call(rbind, coords)
}

#' @export
xyzmatrix.neuron<-function(x, ...) x$d[,c("X","Y","Z")]

#' @export
xyzmatrix.dotprops<-function(x, ...) x$points

#' @method xyzmatrix default
#' @param y,z separate y and z coordinates
#' @details Note that \code{xyzmatrix} can extract or set 3d coordinates in a 
#'   \code{matrix} or \code{data.frame} that \bold{either} has exactly 3 columns
#'   \bold{or} has 3 columns named X,Y,Z or x,y,z.
#' @rdname xyzmatrix
#' @export
xyzmatrix.default<-function(x, y=NULL, z=NULL, ...) {
  xyzn=c("X","Y","Z")
  if(is.neuron(x,Strict=FALSE)) {
    x=x$d[,c("X","Y","Z")]
  } else if(!is.null(z)){
    x=cbind(x,y,z)
  } else if(is.data.frame(x) || is.matrix(x)){
    if(ncol(x)>3){
      matched_cols=match(xyzn, toupper(colnames(x)))
      if(!any(is.na(matched_cols))) x=x[,matched_cols]
      else stop("Ambiguous column names. Unable to retrieve XYZ data")
    } else if(ncol(x)<3) stop("Must have 3 columns of XYZ data")
  }
  mx=data.matrix(x)
  colnames(mx)=xyzn
  mx
}

#' @export
xyzmatrix.hxsurf<-function(x, ...) {
  # quick function that gives a generic way to extract coords from 
  # classes that we care about and returns a matrix
  # nb unlike xyz.coords this returns a matrix (not a list)
  mx=data.matrix(x$Vertices[,1:3])
  colnames(mx)=c("X","Y","Z")
  mx
}

#' @rdname xyzmatrix
#' @export
xyzmatrix.igraph<-function(x, ...){
  igraph::get.graph.attribute(x, 'xyz')
}

#' @description \code{xyzmatrix<-} assigns xyz elements of neuron or dotprops
#'   object and can also handle matrix like objects with columns named X, Y, Z
#'   or x, y, z.
#' @usage xyzmatrix(x) <- value
#' @param value Nx3 matrix specifying new xyz coords
#' @return Original object with modified coords
#' @export
#' @seealso \code{\link{xyzmatrix}}
#' @rdname xyzmatrix
#' @examples
#' n=Cell07PNs[[1]]
#' xyzmatrix(n)<-xyzmatrix(n)
#' stopifnot(isTRUE(
#'   all.equal(xyzmatrix(n),xyzmatrix(Cell07PNs[[1]]))
#' ))
`xyzmatrix<-`<-function(x, value) UseMethod("xyzmatrix<-")

#' @export
`xyzmatrix<-.default`<-function(x, value){
  xyzn=c("X","Y","Z")
  if(is.neuron(x)) x$d[,xyzn]=value
  else if(is.dotprops(x)) x$points[,xyzn]=value
  else if(!any(is.na(matched_cols<-match(xyzn, toupper(colnames(x)))))) {
    x[,matched_cols]=value
  }
  else stop("Not a neuron or dotprops object or a matrix-like object with XYZ colnames")
  x
}

#' @export
`xyzmatrix<-.hxsurf`<-function(x, value){
  x$Vertices[,1:3]=value
  x
}

#' @export
`xyzmatrix<-.igraph`<-function(x, value){
  igraph::set.graph.attribute(x, 'xyz', value)
}

#' Mirror 3d object about a given axis, optionally using a warping registration
#' 
#' @description mirroring with a warping registration can be used to account 
#'   e.g. for the asymmetry between brain hemispheres.
#'   
#'   This function is agnostic re node vs cell data, but for node data 
#'   BoundingBox should be supplied while for cell, it should be bounds. See 
#'   \code{\link{boundingbox}} for details of BoundingBox vs bounds.
#'   
#'   See \code{\link{nlapply}} for details of the \code{subset} and 
#'   \code{OmitFailures} arguments.
#'   
#' @param x Object with 3d points (with named cols X,Y,Z)
#' @param ... additional arguments passed to methods or eventually to 
#'   \code{xform}
#' @return Object with transformed points
#' @export
#' @seealso \code{\link{xform}, \link{boundingbox}}
#' @examples
#' x=Cell07PNs[[1]]
#' plot3d(x,col='red')
#' plot3d(mirror(x,168),col='green')
#' plot3d(mirror(x,168,transform='flip'),col='blue')
#' y=kcs20[[1]]
#' plot3d(mirror(y,564.2532,transform='flip'),col='red')
#' plot3d(mirror(y,mirrorAxisSize=564.2532,transform='flip'),col='blue')
mirror<-function(x, ...) UseMethod('mirror')

#' @param mirrorAxisSize The bounding box of the axis to mirror
#' @param mirrorAxis Axis to mirror (default \code{"X"}). Can also be an integer
#'   in range \code{1:3}.
#' @param warpfile Path to (optional) CMTK registration that specifies a
#'   (usually non-rigid) transformation to be applied \emph{after} the simple
#'   mirroring.
#' @param transform whether to use warp (default) or affine component of 
#'   registration, or simply flip about midplane of axis.
#' @method mirror default
#' @export
#' @rdname mirror
mirror.default<-function(x, mirrorAxisSize, mirrorAxis=c("X","Y","Z"),
                         warpfile=NULL, transform=c("warp",'affine','flip'), ...){
  transform=match.arg(transform)
  if(is.character(mirrorAxis)) {
    mirrorAxis=match.arg(mirrorAxis)
    mirrorAxis=match(mirrorAxis,c("X","Y","Z"))
  }
  if(length(mirrorAxis)!=1 || is.na(mirrorAxis) || mirrorAxis<0 || mirrorAxis>3)
    stop("Invalid mirror axis")
  
  # construct homogeneous affine mirroring transform
  mirrormat=diag(4)
  mirrormat[mirrorAxis, 4]=mirrorAxisSize
  mirrormat[mirrorAxis, mirrorAxis]=-1
  
  if(is.null(warpfile) || transform=='flip') {
    xform(x, reg=mirrormat, ...)
  } else {
    # only apply xform once since this looks after e.g. recalculating dotprops
    # vectors
    xyzmatrix(x)=xformpoints(xyzmatrix(x), reg = mirrormat)
    xform(x, reg=warpfile, transformtype=transform, ...)
  }
}
#' @method mirror neuronlist
#' @param subset For \code{mirror.neuronlist} indices
#'   (character/logical/integer) that specify a subset of the members of
#'   \code{x} to be transformed.
#' @inheritParams nlapply
#' @export
#' @rdname mirror
#' @seealso \code{\link{nlapply}}
mirror.neuronlist<-function(x, subset=NULL, OmitFailures=NA, ...){
  nlapply(x, FUN=mirror, ..., subset=subset, OmitFailures=OmitFailures)
}
