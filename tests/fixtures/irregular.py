def process(items, start):
    total = start
    for item in items:
        if item > 0:
            total += item
        else:
            total -= item
    return total
