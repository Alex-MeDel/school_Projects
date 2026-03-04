import re

# 1. Greedy vs Non-Greedy Matching
text = "<a>Link1</a> <a>Link2</a> <a>Link3</a>"

# Greedy matching
greedy_pattern = r"<a>.*</a>"
greedy_match = re.search(greedy_pattern, text)
print("Greedy Match:", greedy_match.group())

# Non-greedy matching
non_greedy_pattern = r"<a>.*?</a>"
non_greedy_matches = re.findall(non_greedy_pattern, text)
print("Non-Greedy Matches:", non_greedy_matches)

def extract_phone_numbers(text):
    phone_pattern = r"(\d{3})-(\d{3})-(\d{4})"
    matches = re.finditer(phone_pattern, text)
    
    results = []
    for match in matches:
        full_number = match.group(0)
        area_code = match.group(1)
        prefix = match.group(2)
        line_number = match.group(3)
        results.append({
            'full_number': full_number,
            'area_code': area_code,
            'prefix': prefix,
            'line_number': line_number
        })
    
    return results

# Example usage
text = "My phone numbers are 123-456-7890 and 987-654-3210."
phone_numbers = extract_phone_numbers(text)

for phone in phone_numbers:
    print("Full phone number:", phone['full_number'])
    print(f"Area code: {phone['area_code']}, Prefix: {phone['prefix']}, Line number: {phone['line_number']}")
    print()

def find_memory_sizes(text):
    memory_pattern = r"\b\d+(\.\d+)?\s?(KB|MB|GB|TB|kb|mb|gb|tb)\b"
    matches = re.findall(memory_pattern, text)
    
    # Reconstruct the full memory size strings
    memory_sizes = [f"{size[0]}{size[1]}" for size in matches]
    return memory_sizes

# Example usage
text = "My laptop has 16GB RAM, and my external drive has 2.5TB storage. Also 1024 KB cache."
memory_sizes = find_memory_sizes(text)
print("Extracted memory sizes:", memory_sizes)

