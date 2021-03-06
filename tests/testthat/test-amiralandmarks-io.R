context("amira landmarks io")

test_that("we can read unpaired Amira landmarks",{
  testData=matrix(rnorm(15),ncol=3)
  tmpfile=tempfile()
  write.amiralandmarks(testData,tmpfile)
  testData.new=read.amiralandmarks(tmpfile)
  unlink(tmpfile)
  names(testData.new)<-NULL
  expect_equal(testData,testData.new,tol=1e-6)
})

test_that("we can read/write paired Amira Landmarks",{
  testData=replicate(2,matrix(rnorm(15),ncol=3),simplify=FALSE)
  tmpfile=tempfile()
  
  write.amiralandmarks(testData,tmpfile)
  testData.new=read.amiralandmarks(tmpfile)
  unlink(tmpfile)
  names(testData.new)<-NULL
  expect_equal(testData,testData.new,tol=1e-6)	
})
