## MNIST dataset

# devtools::install_github("rstudio/keras")
library(keras)
# keras::install_keras()

mnist <- dataset_mnist()
x_train <- mnist$train$x
y_train <- mnist$train$y
x_test <- mnist$test$x
y_test <- mnist$test$y

## flatten
# reshape
x_train <- array_reshape(x_train, c(nrow(x_train), 784))
x_test <- array_reshape(x_test, c(nrow(x_test), 784))
# rescale
x_train <- x_train / 255
x_test <- x_test / 255

# "0", "1",.., "9"
y_train <- to_categorical(y_train, 10)
y_test <- to_categorical(y_test, 10)

# sequential model, adding layers
model <- keras_model_sequential()
model %>%
  layer_dense(units = 256, activation = 'relu', input_shape = c(784)) %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 10, activation = 'softmax')

# summary
summary(model)

# compile the model with the appropriate loss function, optimizer and metrics
model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_rmsprop(),
  metrics = c('accuracy')
)

# use fit() to train the model for 30 epochs using batches of 128 images
history <- model %>% fit(
  x_train, y_train,
  epochs = 30, batch_size = 128,
  validation_split = 0.2
)

# model performance evaluation
model %>% evaluate(x_test, y_test)

# predictions
model %>% predict_classes(x_test)
model %>% predict(x) %>% k_argmax()

##########################
# test reticulate
library(reticulate)
py_eval("1+1")


##################
# varia
install.packages("keras")
install.packages("tensorflow")
install.packages("reticulate")


library(keras)

# Initialize the sequential model
model <- keras_model_sequential()

# Add the first dense layer
model <- model %>%
  layer_dense(units = 32, activation = 'relu', input_shape = c(10))

# Add the output layer
model <- model %>%
  layer_dense(units = 1, activation = 'sigmoid')




