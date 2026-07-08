# 컴퓨터 부품 데이터셋 (세모표 신규 카테고리)

컴퓨터 성능 시뮬레이션·비교 기능용 부품 데이터. 기존 세모표 파이프라인(`data/*.csv` → `scripts/` 검증 → `assets/data/*.json`)에 그대로 얹는 형식입니다.

## 파일 & 규모

위치: `data/pc_parts/`

| 부품 | 파일 | 행수 |
|------|------|------|
| CPU | `cpu.csv` | 50 |
| GPU | `gpu.csv` | 52 |
| RAM | `ram.csv` | 50 |
| SSD | `ssd.csv` | 50 |
| HDD | `hdd.csv` | 50 |
| WiFi | `wifi.csv` | 50 |

## 공통 규칙 (기존 프로젝트 원칙 준수)

- **성능 = 공식스펙**: 요청대로 제조사 공식 표기값만 수집(클럭/코어/용량/속도/TDP 등). 벤치마크 실측은 미포함.
- **가격**: 원화(`price_krw`) + 달러(`price_usd`) 병기. 2026-07 기준 대략치이며 `note`에 명시. 가격은 변동성이 커서 신뢰도가 스펙보다 낮음.
- **reliability**: 상/중/하 — 공식스펙 확인 모델은 `상`, 출시 초기·추정 포함은 `중`.
- **source**: 스펙 출처(제조사 spec / Intel ARK / NVIDIA·AMD official 등).
- 값을 지어내지 않음. 불확실 항목은 `중` + note 처리.

## 컬럼 스키마

**cpu_specs**: name, brand, socket, cores, threads, base_clock_ghz, boost_clock_ghz, tdp_w, launch_year, price_krw, price_usd, reliability, source, note

**gpu_specs**: name, brand, architecture, vram_gb, vram_type, boost_clock_mhz, tdp_w, launch_year, price_krw, price_usd, reliability, source, note

**ram_specs**: name, brand, type, capacity_gb, kit_config, speed_mts, cas_latency, voltage_v, price_krw, price_usd, reliability, source, note

**ssd_specs**: name, brand, interface, form_factor, capacity_gb, seq_read_mbps, seq_write_mbps, tbw, price_krw, price_usd, reliability, source, note

**hdd_specs**: name, brand, capacity_tb, rpm, cache_mb, interface, form_factor, launch_year, price_krw, price_usd, reliability, source, note

**wifi_specs**: name, brand, type, standard, bands, max_speed_mbps, antennas, interface, price_krw, price_usd, reliability, source, note

## 커버리지

- CPU: AMD Ryzen 5000~9000(X3D 포함) + Intel 12~14세대 Core, Core Ultra 200S/200S Plus
- GPU: NVIDIA RTX 30/40/50, AMD RX 6000/7000/9000(RDNA4), Intel Arc A/B 시리즈
- RAM: DDR4 / DDR5, 8~64GB, 3200~8000 MT/s
- SSD: SATA / NVMe PCIe 3·4·5
- HDD: 500GB~24TB, 5400·5900·7200 RPM, 일반/NAS/엔터프라이즈/CCTV/노트북
- WiFi: PCIe 카드 / USB 어댑터 / M.2 모듈 / 공유기, WiFi 5·6·6E·7

## 시뮬레이션 활용 팁

성능 점수를 뽑을 때 공식스펙 조합으로 간이 지표를 만들 수 있음:
- CPU 근사 성능 ≈ cores × boost_clock (멀티스레드) / boost_clock (싱글)
- GPU 근사 성능 ≈ vram·아키텍처·boost_clock 가중
- 저장장치 ≈ seq_read/write, RPM
- 가성비 = 성능지표 / price

> 실측 벤치마크(PassMark·3DMark 등)를 나중에 별도 컬럼으로 붙이면 세모표 핵심인 "공식 vs 체감(실측) 갭"까지 확장 가능.
