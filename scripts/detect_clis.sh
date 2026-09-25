#!/bin/bash
# factcheck-pipeline: 설치된 AI CLI와 사용 가능한 최신 모델 탐지
# 출력: 도구별 상태(설치 여부·경로·모델 후보) — 사람이 읽는 요약 + 마지막에 AVAILABLE= 목록

echo "=== AI CLI 탐지 결과 ==="
AVAILABLE=()

# --- Codex (OpenAI) ---
if command -v codex >/dev/null 2>&1; then
  MODEL=$(grep -m1 '^model' ~/.codex/config.toml 2>/dev/null | sed 's/.*= *"\(.*\)"/\1/')
  echo "[codex]  설치됨: $(command -v codex) | 기본 모델: ${MODEL:-확인 필요(~/.codex/config.toml)}"
  AVAILABLE+=("codex")
else
  echo "[codex]  없음 (설치: npm install -g @openai/codex)"
fi

# --- Antigravity/agy (Google Gemini) ---
if command -v agy >/dev/null 2>&1; then
  echo "[agy]    설치됨: $(command -v agy) | 모델 목록: 'agy models' 실행 (Pro 계열 최상위 권장)"
  agy models 2>/dev/null | grep -iE "pro" | head -3 | sed 's/^/         └ /'
  AVAILABLE+=("agy")
else
  echo "[agy]    없음 (Antigravity 설치 필요 — antigravity.google)"
fi

# --- 구 gemini CLI (참고용 — 개인 계정 지원 종료 사례 많음) ---
if command -v gemini >/dev/null 2>&1 && ! command -v agy >/dev/null 2>&1; then
  echo "[gemini] 설치됨(구 CLI) — 개인 계정은 IneligibleTierError 가능. agy 이관 권장"
  AVAILABLE+=("gemini")
fi

# --- Grok (xAI) ---
if command -v grok >/dev/null 2>&1; then
  echo "[grok]   설치됨: $(command -v grok) | 모델 목록:"
  grok models 2>/dev/null | grep -E "^\s*[\*\-]" | head -4 | sed 's/^/         └ /'
  AVAILABLE+=("grok")
else
  echo "[grok]   없음 (설치: grok.com CLI 안내 참조)"
fi

# --- Claude (현재 세션 — 최종 판정 모델 후보) ---
echo "[claude] 현재 세션 자체 — 최종 판정(교차 종합) 모델 기본 후보"

echo ""
echo "AVAILABLE=${AVAILABLE[*]}"
