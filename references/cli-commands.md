# 도구별 실행 명령과 함정 회피

실제 운영에서 겪은 함정들이 반영된 명령 템플릿. `<파일명>`은 확장자 제외 베이스명, `<절대경로>`는 대상 문서의 절대 경로, `<프롬프트>`는 SKILL.md 3단계의 공통 프롬프트 골격.

## Codex (OpenAI)

```bash
codex exec --skip-git-repo-check -m <최신모델> --sandbox read-only \
  -c tools.web_search=true \
  -o "<파일명>_팩트체크_codex.md" \
  "<프롬프트>" </dev/null 2>/tmp/codex_err.log
```

| 함정 | 회피 |
|---|---|
| `--search`는 `exec` 하위명령 플래그가 아님 | `-c tools.web_search=true` 사용 |
| git 저장소 밖이면 실행 거부 | `--skip-git-repo-check` 필수 |
| 프롬프트 내 `$` 셸 확장(예: `$375M` → 증발) | `$` 회피 — 수치는 한글/영문 서술로 |
| stdout에 진행 로그 섞임 | `-o 파일`로 최종 답변만 저장 (완료 시점 일괄 기록 — 실행 중엔 빈 파일이 정상) |
| stdin 대기 | `</dev/null` 리다이렉트 |

최신 모델 확인: `~/.codex/config.toml`의 `model` 값.

## Antigravity/agy (Google Gemini)

```bash
agy --add-dir <문서 폴더> --dangerously-skip-permissions \
  --model <Pro계열 최신> --effort high --print-timeout 20m \
  -p "<프롬프트> (파일: <파일명>)" \
  > "<파일명>_팩트체크_gemini.md" 2>/tmp/agy_err.log
```

- 모델 목록: `agy models` — 팩트체크는 플래시가 아닌 **Pro/high 계열** 선택
- `--add-dir`로 문서 폴더를 워크스페이스에 추가해야 파일을 읽을 수 있다
- 구 `gemini` CLI는 개인 계정 IneligibleTierError 가능 — agy 우선

## Grok (xAI)

```bash
cd <문서 폴더> && grok --always-approve -m <최신모델> \
  -p "현재 폴더의 '<파일명>.md' 파일을 읽고 <프롬프트 본문>" \
  > "<파일명>_팩트체크_grok.md" 2>/tmp/grok_err.log
```

- 모델 목록: `grok models`
- 에이전트형이라 파일을 직접 읽는다 — `--always-approve`로 도구 승인 자동화
- 출력 앞부분에 진행 서술이 섞일 수 있음 — 종합 시 표 부분 위주로 읽기

## 공통

- **병렬 실행**: 각 명령을 백그라운드로 동시에 실행 (도구당 3~15분 소요)
- **쿼터/인증 실패 감지**: err.log에서 quota, rate limit, 429, billing, insufficient, IneligibleTier 등 발견 시 즉시 사용자 보고 → 남은 도구로 계속할지 질문
- **빈 결과 파일**: `-o`/리다이렉트 방식은 완료 시점에 기록됨 — 실행 중 0바이트는 정상. 종료 후에도 0바이트면 err.log 확인
