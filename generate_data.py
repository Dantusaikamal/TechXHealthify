import pandas as pd
import numpy as np

# Set random seed for reproducibility
np.random.seed(123)

# Generate dummy data
num_samples = 1000

gender = np.random.choice(['Male', 'Female'], size=num_samples)
bmi = np.random.normal(loc=25, scale=3, size=num_samples)
heartRate = np.random.normal(loc=70, scale=10, size=num_samples)
fatRate = np.random.normal(loc=25, scale=5, size=num_samples)
deepSleepTime = np.random.normal(loc=120, scale=30, size=num_samples)
shallowSleepTime = np.random.normal(loc=240, scale=30, size=num_samples)
wakeTime = np.random.normal(loc=30, scale=10, size=num_samples)
start = np.random.choice(['Morning', 'Afternoon', 'Evening'], size=num_samples)
stop = np.random.choice(['Morning', 'Afternoon', 'Evening'], size=num_samples)
REMTime = np.random.normal(loc=90, scale=30, size=num_samples)
naps = np.random.choice([0, 1], size=num_samples)
steps = np.random.normal(loc=8000, scale=2000, size=num_samples)
distance = np.random.normal(loc=5, scale=2, size=num_samples)
runDistance = np.random.normal(loc=2, scale=1, size=num_samples)
calories = np.random.normal(loc=2000, scale=500, size=num_samples)
heart_stroke = np.random.choice([0, 1], size=num_samples)

# Combine data into a pandas DataFrame
df = pd.DataFrame({
    'gender': gender,
    'bmi': bmi,
    'heartRate': heartRate,
    'fatRate': fatRate,
    'deepSleepTime': deepSleepTime,
    'shallowSleepTime': shallowSleepTime,
    'wakeTime': wakeTime,
    'start': start,
    'stop': stop,
    'REMTime': REMTime,
    'naps': naps,
    'steps': steps,
    'distance': distance,
    'runDistance': runDistance,
    'calories': calories,
    'heart_stroke': heart_stroke
})

# Save data to a CSV file
df.to_csv('dummy_data.csv', index=False)
