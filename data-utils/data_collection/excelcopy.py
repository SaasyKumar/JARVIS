# Excel use TSV - Tab Seperated Value
#2d data
samle_data = [
    ["Name", "Age", "City"],
    ["Alice", "30", "Mumbai"],
    ["Bob", "25", "Delhi"]
]
def listToTSV(data):
    #every thing inside the list sould be a string
    return "\n".join("\t".join(map(str, row)) for row in data)
