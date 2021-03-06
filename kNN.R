######
# kNN
######

# Do not clear your workspace

# load required libraries
require(class) # for kNN classifier
require(caret) # for createDataPartition, train, predict
require(randomForest) # for random forest classifier
require(MASS) # for neural net classifier

# set seed to ensure reproducibility
set.seed(100)

# load in-built dataset
data(iris)

# normalize all predictors, i.e., all but last column species
iris[, -ncol(iris)] <- scale(iris[, -ncol(iris)])

# split the data into training and test sets 70/30 split
# take a partition of the indexes then use the index vectors to subset
###
trainIdx <- createDataPartition(iris$Species, p = 0.7, list = FALSE)
# those Idxs in original data but not in trainIdx will form testIdx
###
testIdx <- setdiff(seq_len(nrow(iris)), trainIdx)
# subset the original dataset with trainIdx and testIdx, use all but last column
train <- iris[trainIdx, -ncol(iris)]
test <- iris[testIdx, -ncol(iris)]

# create a factor for the training data class variable
###
cl <- factor(iris[trainIdx,ncol(iris) ])

# use random forest from randomForest package to predict
###
RFmodel <- train(train, cl, method = "rf")
RFpreds <- predict(RFmodel, train)

# create contingency table of predictions against ground truth
###
table(RFpreds, factor(iris[trainIdx,ncol(iris)]))

# use neural network from MASS package to predict
###
NNmodel <- train(train,cl , method = "nnet")
NNpreds <- predict(NNmodel, train)

# create contingency table of predictions against ground truth
###
table(NNpreds, factor(iris[trainIdx,ncol(iris)]))

# use knn from class package to predict, use 3 nearest neighbors
###
knnPreds <- knn(train,test ,cl ,k = 3 , prob = TRUE)

# create contingency table of predictions against ground truth
###
table(knnPreds,factor(iris[testIdx,ncol(iris)]))

# implement myknn with manhattan distance, majority vote and 
# resolving ties by priority setosa > versicolor > virginica
myknn <- function(train, test, cl, k)
{
    classes <- vector()
    for(i in 1:nrow(test))
    {
        dists <- vector()
        for(j in 1:nrow(train))
        {
            # implement manhattan distance calculation without using the
            # dist function
            ###
            temp <- abs(test[i,]-train[j,])
            v<-sum(temp)
            dists <- c(dists, v)
        }
        # implement majority vote and resolving ties by priority to assign class
        # functions order, max, which.max and table could be useful
        ###
        majority_vote <- names(which.max(table(cl[order(dists)[1:k]])))
        classes[i] <- majority_vote
        #print(majority_vote)
    }
    return(factor(classes))
}

# predict using your implemented function
myPreds <- myknn(train, test, cl, k = 3)

# create contingency table of predictions against ground truth
###table(myPreds,factor(iris[testIdx,ncol(iris)]))table(myPreds, factor([, ]))

# compare with the knn from class package
table(myPreds, knnPreds)