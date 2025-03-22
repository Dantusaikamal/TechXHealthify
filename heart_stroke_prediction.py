import pandas as pd
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.impute import SimpleImputer
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import GradientBoostingClassifier
from tensorflow import keras
import joblib
import numpy as np


# Data Preparation

data = pd.read_csv('C:\\Users\dantu\OneDrive\Desktop\Heart stroke prediction\Machine Learning model/dummy_data.csv');

# The input features (X) and the target variable (y) are extracted from the dataset.

X = data[['gender', 'bmi', 'heartRate', 'fatRate', 'deepSleepTime', 'shallowSleepTime', 'wakeTime', 'REMTime', 'naps', 'steps', 'distance', 'runDistance', 'calories']].dropna()
y = data['heart_stroke'].dropna()


# Missing values in the input features are handled using the SimpleImputer class from sklearn by replacing them with the mean of the corresponding column.

numerical_cols = ['bmi', 'heartRate', 'fatRate', 'deepSleepTime', 'shallowSleepTime', 'wakeTime', 'REMTime', 'naps', 'steps', 'distance', 'runDistance', 'calories']

imputer = SimpleImputer(strategy='mean')

X[numerical_cols] = imputer.fit_transform(X[numerical_cols])

# The input features are then standardized using the StandardScaler class from sklearn to ensure that all features are on a similar scale.

scaler = StandardScaler()
X[numerical_cols] = scaler.fit_transform(X[numerical_cols])

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Neural Network Model:

# The code defines a neural network model using the Sequential API from TensorFlow's Keras module:

model = keras.Sequential([
    keras.layers.Flatten(input_shape=(X_train.shape[1],)),
    keras.layers.BatchNormalization(),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.BatchNormalization(),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(64, activation='relu'),
    keras.layers.BatchNormalization(),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(1, activation='sigmoid')
])

# The model is compiled with the Adam optimizer, binary cross-entropy loss function, and accuracy as the evaluation metric.
opt = keras.optimizers.Adam(lr=0.001)

# The model is trained on the training data (X_train, y_train) for a specified number of epochs and a batch size
model.compile(optimizer=opt, loss='binary_crossentropy', metrics=['accuracy'])
model.fit(X_train, y_train, epochs=10, batch_size=64, validation_split=0.1)

# The model's performance is evaluated on the test data (X_test) by calculating various metrics such as accuracy, precision, recall, and F1 score.
y_pred_classes = np.argmax(model.predict(X_test), axis=-1)

print('Neural Network Accuracy:', accuracy_score(y_test, y_pred_classes))
print('Neural Network Precision:', precision_score(y_test, y_pred_classes))
print('Neural Network Recall:', recall_score(y_test, y_pred_classes))
print('Neural Network F1 Score:', f1_score(y_test, y_pred_classes))

param_grid = {'C': [0.01, 0.1, 1, 10, 100]}

# Logistic Regression Model:
# The code creates a LogisticRegression model using the LogisticRegression class from sklearn.
    
lr_model = LogisticRegression()

# GridSearchCV is used to perform hyperparameter tuning by searching for the best combination of hyperparameters from the provided parameter grid.
grid_search = GridSearchCV(lr_model, param_grid, cv=5)
grid_search.fit(X_train, y_train)

# The best hyperparameters are then used to train the logistic regression model.
print("Best hyperparameters using Logical regression",grid_search.best_params_)

# The model's performance is evaluated on the test data by calculating metrics such as accuracy, precision, recall, and F1 score.
best_lr_model = LogisticRegression(C=grid_search.best_params_['C'])
best_lr_model.fit(X_train, y_train)

y_pred = best_lr_model.predict(X_test)
print('Accuracy:', accuracy_score(y_test, y_pred))
print('Precision:', precision_score(y_test, y_pred))
print('Recall:', recall_score(y_test, y_pred))
print('F1 Score:', f1_score(y_test, y_pred))

# Create a decision tree model
# The code creates a DecisionTreeClassifier model using the DecisionTreeClassifier class from sklearn.
dt_model = DecisionTreeClassifier()

# Similar to logistic regression, GridSearchCV is used to find the best hyperparameters for the decision tree model
param_grid = {'max_depth': [2, 5, 10, 20, 50, 100]}

grid_search = GridSearchCV(dt_model, param_grid, cv=5)
grid_search.fit(X_train, y_train)

#The best hyperparameters are used to train the decision tree model.
best_dt_model = DecisionTreeClassifier(max_depth=grid_search.best_params_['max_depth'])
best_dt_model.fit(X_train, y_train)

#The model's performance is evaluated on the test data by calculating metrics such as accuracy, precision, recall, and F1 score.
y_pred = best_dt_model.predict(X_test)
print('Decision Tree Accuracy:', accuracy_score(y_test, y_pred))
print('Decision Tree Precision:', precision_score(y_test, y_pred))
print('Decision Tree Recall:', recall_score(y_test, y_pred))
print('Decision Tree F1 Score:', f1_score(y_test, y_pred))

# Create a random forest model
# The code creates a RandomForestClassifier model using the RandomForestClassifier class from sklearn.
rf_model = RandomForestClassifier()

param_grid = {
    'n_estimators': [50, 100, 200],
    'max_depth': [10, 20, 30, None],
    'min_samples_split': [2, 5, 10],
    'min_samples_leaf': [1, 2, 4],
    'max_features': ['sqrt']
    }

# Use GridSearchCV to find the best hyperparameters
grid_search = GridSearchCV(rf_model, param_grid, cv=5)
grid_search.fit(X_train, y_train)

# The best hyperparameters are used to train the random forest model.
best_rf_model = RandomForestClassifier(max_depth=grid_search.best_params_['max_depth'], n_estimators=grid_search.best_params_['n_estimators'])
best_rf_model.fit(X_train, y_train)

# The model's performance is evaluated on the test data by calculating metrics such as accuracy, precision, recall, and F1 score
y_pred = best_rf_model.predict(X_test)
print('Random Forest Accuracy:', accuracy_score(y_test, y_pred))
print('Random Forest Precision:', precision_score(y_test, y_pred))
print('Random Forest Recall:', recall_score(y_test, y_pred))
print('Random Forest F1 Score:', f1_score(y_test, y_pred))


# Gradient Boosting Model:
# The code creates a GradientBoostingClassifier model using the GradientBoostingClassifier class from sklearn.
gb_model = GradientBoostingClassifier()

param_grid = {
    'learning_rate': [0.01, 0.1, 1],
    'n_estimators': [50, 100, 200],
    'max_depth': [3, 5, 10],
    'min_samples_split': [2, 5, 10],
    'min_samples_leaf': [1, 2, 4],
    'max_features': ['sqrt']
}

# Use GridSearchCV to find the best hyperparameters
grid_search = GridSearchCV(gb_model, param_grid, cv=5)
grid_search.fit(X_train, y_train)

# The best hyperparameters are used to train the gradient boosting model.
best_gb_model = GradientBoostingClassifier(max_depth=grid_search.best_params_['max_depth'], n_estimators=grid_search.best_params_['n_estimators'], learning_rate=grid_search.best_params_['learning_rate'])
best_gb_model.fit(X_train, y_train)

# The model's performance is evaluated on the test data by calculating metrics such as accuracy, precision, recall, and F1 score.
y_pred = best_gb_model.predict(X_test)
print('gradient boosting Accuracy:', accuracy_score(y_test, y_pred))
print('gradient boosting Precision:', precision_score(y_test, y_pred))
print('gradient boosting Recall:', recall_score(y_test, y_pred))
print('gradient boosting F1 Score:', f1_score(y_test, y_pred))


# TensorFlow Lite Conversion:
# The code defines a simple neural network model using the Functional API of Keras.
input_shape = (14,)

# Create a new input layer
inputs = keras.Input(shape=input_shape, name='input')

x = keras.layers.Dense(32, activation='relu')(inputs)
x = keras.layers.Dense(1, activation='sigmoid')(x)
model = keras.Model(inputs=inputs, outputs=x)

# Convert the model to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the TensorFlow Lite model to a file
with open('model.tflite', 'wb') as f:
    f.write(tflite_model)