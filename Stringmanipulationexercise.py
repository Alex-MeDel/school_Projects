firstString = "  Alex Medina Delgado  ,  Collin College             "

noExtra_space = firstString.strip()

split = noExtra_space.split(',', 1)
name = split[0].strip()
college = split[1].strip()

nombre_limpio = ' '.join(name.split())
nombreFormateado = nombre_limpio.title()

college_limpio = ' '.join(college.split())
collegeFormateado = college_limpio.title()

hasUni = "College" in collegeFormateado

welcomeMessage = "Welcome, " + nombreFormateado + ", to " + collegeFormateado + "!"

result = welcomeMessage.upper()

print(result)

letter_e = result.count('E')
print(f"Number of E's in the message: {letter_e}")
print('------------------------------------------------')