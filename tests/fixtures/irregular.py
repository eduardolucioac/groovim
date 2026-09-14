def processar(itens):
    total = 0
    for item in itens:
        if item > 0:
            total += item
        else:
            total -= item
    return total
