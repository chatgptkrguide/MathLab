#!/usr/bin/env python3
"""
PDF에서 추출한 수학 문제를 JSON 형식으로 변환하는 스크립트

사용법:
    python3 convert_pdf_problems.py

입력: PDF에서 추출한 문제 데이터 (딕셔너리 형식)
출력: assets/data/polynomial_problems_full.json
"""

import json
import re

# PDF에서 추출한 문제 데이터 (60문제 전체)
# 실제로는 PDF 파싱 라이브러리를 사용하거나 수동으로 입력
problems_data = [
    {
        "number": 1,
        "code": "공수1_다항식연산_L2_ICM",
        "question": "다항식 $$4x^3+2x-1$$에 어떤 식을 더해야 할 것을 잘못하여 뺐더니 $$x^3+x^2+3x-2$$가 되었다고 할 때, 바르게 계산한 답은?",
        "options": [
            "$$-3x^3+x^2+x-1$$",
            "$$3x^3-x^2-x+1$$",
            "$$5x^3+x^2+5x-3$$",
            "$$7x^3-x^2+x$$",
            "$$9x^3+x^2+7x-4$$"
        ],
        "answer_index": 3,
        "explanation": "잘못 뺀 식을 $$A$$라 하면 $$4x^3+2x-1-A=x^3+x^2+3x-2$$에서 $$A=3x^3-x^2-x+1$$\n따라서 바르게 계산한 답은 $$4x^3+2x-1+A=7x^3-x^2+x$$",
        "hints": ["잘못 뺀 식을 치환하여 구하세요", "바르게 계산하려면 구한 식을 더해야 합니다"]
    },
    # 나머지 59개 문제는 여기에 추가...
]

def convert_problem_to_json(problem_data, index):
    """
    문제 데이터를 JSON 형식으로 변환

    Args:
        problem_data (dict): 원본 문제 데이터
        index (int): 문제 번호

    Returns:
        dict: JSON 형식의 문제 데이터
    """
    # 난이도 및 측정요소 파싱
    code_parts = problem_data.get('code', '').split('_')
    difficulty = 2  # 기본값
    assessment_elements = []

    if len(code_parts) >= 4:
        difficulty_str = code_parts[2]
        difficulty = int(difficulty_str.replace('L', ''))

        assessment_str = code_parts[3] if len(code_parts) > 3 else 'ICA'
        assessment_elements = list(assessment_str)

    return {
        "id": f"poly{str(index+1).zfill(3)}",
        "lessonId": "lesson_poly_add_sub",
        "type": "multipleChoice",
        "subject": "공통수학1",
        "chapter": "다항식의 연산",
        "section": "01 다항식의 덧셈과 뺄셈",
        "problemCode": problem_data.get('code', ''),
        "question": problem_data.get('question', ''),
        "category": "다항식의 덧셈과 뺄셈",
        "difficulty": difficulty,
        "difficultyLevel": f"L{difficulty}",
        "assessmentElements": assessment_elements,
        "tags": extract_tags_from_code(assessment_elements),
        "xpReward": 15 if difficulty <= 2 else 20,
        "options": problem_data.get('options', []),
        "correctAnswerIndex": problem_data.get('answer_index', 0),
        "correctAnswer": problem_data['options'][problem_data.get('answer_index', 0)],
        "explanation": problem_data.get('explanation', ''),
        "hints": problem_data.get('hints', []),
        "solution": problem_data.get('solution', problem_data.get('explanation', ''))
    }

def extract_tags_from_code(assessment_elements):
    """
    측정요소 코드에서 태그 추출

    Args:
        assessment_elements (list): 측정요소 리스트 ['I', 'C', 'M' 등]

    Returns:
        list: 태그 리스트
    """
    tags = ["다항식"]

    element_map = {
        'I': '문제해석',
        'R': '그래프해석',
        'C': '계산',
        'A': '개념적용',
        'M': '추론'
    }

    for elem in assessment_elements:
        if elem in element_map:
            tags.append(element_map[elem])

    return tags

def main():
    """메인 함수"""
    print("=" * 60)
    print("PDF 문제 데이터를 JSON 형식으로 변환 중...")
    print("=" * 60)

    # 문제 변환
    converted_problems = []
    for idx, problem in enumerate(problems_data):
        converted = convert_problem_to_json(problem, idx)
        converted_problems.append(converted)
        print(f"[{idx+1}/{len(problems_data)}] {problem.get('code', 'Unknown')} 변환 완료")

    # JSON 파일로 저장
    output_data = {
        "problems": converted_problems,
        "metadata": {
            "subject": "공통수학1",
            "chapter": "다항식의 연산",
            "section": "01 다항식의 덧셈과 뺄셈",
            "totalProblems": len(converted_problems),
            "difficulty": "L2-L3",
            "source": "공통수학1_L2_L3.pdf"
        }
    }

    output_path = "../assets/data/polynomial_problems_full.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)

    print("\n" + "=" * 60)
    print(f"✓ 변환 완료! 총 {len(converted_problems)}개의 문제")
    print(f"✓ 출력 파일: {output_path}")
    print("=" * 60)

if __name__ == "__main__":
    main()
