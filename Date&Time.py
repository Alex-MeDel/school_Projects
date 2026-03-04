import time
import datetime


# Task 1: Get the Current Date and Time
print("----------------------------------")
print("Task 1:")

c_datetime = datetime.datetime.now()
print(f"Today's Date: {c_datetime.strftime('%Y-%m-%d')}") 
print(f"Current Time: {c_datetime.strftime('%H:%M:%S')}")

# Task 2: Format and Parse Dates
print("----------------------------------")
print("Task 2:")

egDate = "2023-7-12 15:45:30"

datetime_object = datetime.datetime.strptime(egDate, "%Y-%m-%d %H:%M:%S")
reformatted_date = datetime_object.strftime("%B %d, %Y at %I:%M %p")

print("Original Date & Time:", egDate)
print("Reformatted Date & Time:", reformatted_date)

# Task 3: Working with timedelta
print("----------------------------------")
print("Task 3:")

today = datetime.date.today()

oneWeek_later = today + datetime.timedelta(weeks=1)
thirtyDays_ago = today - datetime.timedelta(days=30)
hundredDays_later = today + datetime.timedelta(days=100)

print(f"Today's Date: {today.strftime('%Y-%m-%d')}")
print(f"One week from today: {oneWeek_later.strftime('%Y-%m-%d')}")
print(f"30 days ago: {thirtyDays_ago.strftime('%Y-%m-%d')}")
print(f"100 days in the future: {hundredDays_later.strftime('%Y-%m-%d')}")

# Task 4: Countdown Timer
print("----------------------------------")
print("Task 4:")

try:
    seconds = int(input("Enter the number of seconds for countdown timer: "))
    
    for i in range(seconds, 0, -1):
        print(f"Remaining: {i} seconds")
        time.sleep(1)
    print("Time's up!")
except ValueError:
    print("Not a valid number! :C ")

