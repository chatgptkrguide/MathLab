import re

# Read the file
with open('lib/data/services/mock_data_service.dart', 'r') as f:
    content = f.read()

# Pattern to match old Problem constructors with their fields
def fix_problem(match):
    full = match.group(0)
    
    # Extract fields using regex
    id_match = re.search(r"id:\s*'([^']+)'", full)
    lesson_match = re.search(r"lessonId:\s*'([^']+)'", full)
    type_match = re.search(r"type:\s*(ProblemType\.\w+)", full)
    question_match = re.search(r"question:\s*'([^']+(?:'\s*\n\s*'[^']+)*)'", full, re.DOTALL)
    category_match = re.search(r"category:\s*'([^']+)'", full)
    difficulty_match = re.search(r"difficulty:\s*(\d+)", full)
    tags_match = re.search(r"tags:\s*(\[[^\]]+\])", full, re.DOTALL)
    xp_match = re.search(r"xpReward:\s*(\d+)", full)
    options_match = re.search(r"options:\s*(\[[^\]]+\])", full, re.DOTALL)
    correct_idx_match = re.search(r"correctAnswerIndex:\s*(\d+)", full)
    correct_ans_match = re.search(r"correctAnswer:\s*'([^']+)'", full)
    explan_match = re.search(r"explanation:\s*'([^']+(?:'\s*\n\s*'[^']+)*)'", full, re.DOTALL)
    hints_match = re.search(r"hints:\s*(\[[^\]]+\])", full, re.DOTALL)
    
    # Build new Problem constructor
    new_constructor = "Problem(\n"
    if id_match:
        new_constructor += f"        id: '{id_match.group(1)}',\n"
    
    # Generate title from category and difficulty
    title = f"{category_match.group(1) if category_match else '문제'} {difficulty_match.group(1) if difficulty_match else '1'}"
    new_constructor += f"        title: '{title}',\n"
    
    if type_match:
        new_constructor += f"        type: {type_match.group(1)},\n"
    if question_match:
        new_constructor += f"        question: {question_match.group(1)},\n"
    if category_match:
        new_constructor += f"        category: '{category_match.group(1)}',\n"
    if difficulty_match:
        new_constructor += f"        difficulty: {difficulty_match.group(1)},\n"
    if options_match:
        new_constructor += f"        choices: {options_match.group(1)},\n"
    if correct_idx_match:
        new_constructor += f"        answer: {correct_idx_match.group(1)},\n"
    if explan_match:
        new_constructor += f"        explanation: {explan_match.group(1)},\n"
    if hints_match:
        new_constructor += f"        hints: {hints_match.group(1)},\n"
    
    # Add metadata
    new_constructor += "        metadata: {\n"
    if lesson_match:
        new_constructor += f"          'lessonId': '{lesson_match.group(1)}',\n"
    if tags_match:
        new_constructor += f"          'tags': {tags_match.group(1)},\n"
    if xp_match:
        new_constructor += f"          'xpReward': {xp_match.group(1)},\n"
    new_constructor += "        },\n"
    new_constructor += "      )"
    
    return new_constructor

# Fix all Problem constructors
pattern = r'Problem\(\s*id:[^)]+(?:hints:[^)]+\],\s*\)|explanation:[^)]+\))'
content = re.sub(pattern, fix_problem, content, flags=re.DOTALL)

# Write back
with open('lib/data/services/mock_data_service.dart', 'w') as f:
    f.write(content)

print("Fixed all Problem constructors")
