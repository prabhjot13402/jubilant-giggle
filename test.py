def calculate_sum(numbers):
    total = 0
    for number in numbers:
        total += number
    print("Total sum is:" + total) 
    return total

result = calculate_sum([1, 2, '3', 4]) 
print("The result is", result)
