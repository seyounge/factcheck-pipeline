# factcheck-pipeline

**Claude Code 스킬 — 다중 AI 모델 교차 팩트체크 파이프라인**

여러 AI CLI(OpenAI Codex, Google Gemini/Antigravity, xAI Grok)가 리서치 문서를 **독립적으로 웹 검증**하고, 사용자가 선택한 최종 판정 모델이 결과를 **교차 종합**해 최종 팩트체크 보고서를 만드는 Claude Code 스킬입니다.

## 왜 필요한가

단일 모델의 셀프 체크는 자기 오류를 놓칩니다. 실제 의료 리서치 문서 검증에서 이 파이프라인은 다음을 잡아냈습니다:

- 논문 제1저자 오기
- 연구 성과를 상업 제품 성과로 오귀속
- 제품 알림 규칙의 구버전 인용
- 정부 사업 시행일 오류
- FDA 인허가 기준 미세 오류 (12kg "초과" vs "이상")

특히 3중 체크에서 **한 모델만 잡아낸 오류**(논문 알고리즘 ≠ 현행 제품 UI)와, 반대로 **한 모델의 오판을 다른 두 모델이 기각**한 사례가 모두 나왔습니다 — 교차 검증이 양방향으로 작동합니다.

## 동작 흐름

```
① 설치된 AI CLI 자동 탐지 (codex / agy / grok + 최신 모델)
② 사용자 선택 — 검증 도구(복수) + 최종 판정 모델 + 검증 깊이(1·2·3회)
③ 병렬 팩트체크 (백그라운드) → <문서>_팩트체크_<도구>.md
④ 최종 판정 모델의 교차 종합
   · 2개 이상 모델 일치 지적 → 우선 반영
   · 단독 지적 → 1차 출처 재확인 후 판정
   · 상충 시 → 1차 출처가 항상 이김
⑤ 최종 보고서 <문서>_팩트체크_최종.md (지적 모델·재검증 방법 컬럼 포함)
⑥ (선택) 정정 반영본 _v2 포킹 — 원본은 절대 덮어쓰지 않음
⑦ 깊이 2·3회: 정정본을 다시 팩트체크하는 라운드 반복
   · 라운드마다 검증 각도 변주 (전반 → 서지·수치 → 최신성·현행성)
   · 신규 지적 0건이면 조기 종료 — 최종 보고서에 라운드별 수렴 표 기록
```

## 검증 깊이 옵션

| 깊이 | 동작 | 용도 |
|---|---|---|
| **1회** (기본) | 단일 패스 검증 | 빠른 확인 |
| **2회** (권장) | 검증 → 정정본 생성 → **정정본 재검증** | 잔존 오류 + 정정 과정에서 생긴 오류까지 |
| **3회** (가장 deep) | 최대 3라운드 검증→정정→재검증 루프 | 발표자료·대외 인용 등 중요 문서 |

## 설치

**방법 ① — Claude Code에 주소만 주면 끝 (가장 쉬움)**

Claude Code 대화창에:

```
> https://github.com/seyounge/factcheck-pipeline 이거 스킬로 설치해줘
```

**방법 ② — 터미널에서 직접**

```bash
git clone https://github.com/seyounge/factcheck-pipeline.git \
  ~/.claude/skills/factcheck-pipeline
```

둘 다 새 Claude Code 세션에서 자동 인식됩니다. 확인: `> factcheck-pipeline 스킬 있어?`

### 전제 조건

검증 도구 CLI 중 **1개 이상** 설치·로그인 (많을수록 교차 검증력 상승):

| CLI | 제공 | 설치 |
|---|---|---|
| `codex` | OpenAI | `npm install -g @openai/codex` |
| `agy` | Google (Antigravity) | antigravity.google |
| `grok` | xAI | grok.com CLI 안내 |

## 사용법

Claude Code 대화창에 평문으로:

```
> research/사례조사.md 팩트체크 파이프라인 돌려줘
> 이 문서 중요하니까 3중 교차 팩트체크 해줘
```

스킬이 CLI를 탐지하고 도구·판정 모델을 물어본 뒤 나머지는 자동 진행합니다.

## 파일 구성

```
factcheck-pipeline/
├── SKILL.md                    # 스킬 본문 (6단계 워크플로우)
├── scripts/detect_clis.sh      # CLI·모델 탐지
├── references/cli-commands.md  # 도구별 명령 템플릿 + 함정 회피
└── README.md
```

## License

MIT
