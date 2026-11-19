# Studio Proyek 3: Fine-Tuning Transformer Pretrained untuk Klasifikasi Sentimen Bahasa Indonesia (SmSA)

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.x-EE4C2C.svg)](https://pytorch.org/)
[![HuggingFace](https://img.shields.io/badge/%F0%9F%A4%97-Transformers-yellow.svg)](https://huggingface.co/)
[![Dataset](https://img.shields.io/badge/Dataset-SmSA%20(IndoNLU)-green.svg)](https://github.com/indobenchmark/indonlu)

Repositori ini memuat implementasi dan hasil eksperimen **Studio Proyek 3 — Pembelajaran Mendalam (IF25-40401)**: perbandingan
3 *backbone* Transformer (monolingual Indonesia vs multilingual) di bawah 3 strategi *fine-tuning* pada dataset sentimen Bahasa Indonesia
**SmSA (IndoNLU)**, untuk merekomendasikan kombinasi yang paling sesuai dengan anggaran komputasi, kecepatan inferensi, dan keterjelasan.

---

## 👥 Tim Penyusun (Kelompok 11 - Yolo)

**Program Studi Teknik Informatika — Institut Teknologi Sumatera (ITERA)**

| Nama Anggota | NIM |
|:---|:---:|
| **Sigit Kurnia Hartawan** | `123140033` |
| **Muhammad Romadhon Santoso** | `123140031` |

---

## 🔗 Tautan Akses Proyek

| Sumber Daya | Tautan Akses | Keterangan |
|:---|:---|:---|
| **Google Drive** | [s.itera.id/Drive_Studio3-NLP_Kelompok11](https://s.itera.id/Drive_Studio3-NLP_Kelompok11) | Folder output: CSV hasil, grafik, dan model terbaik |
| **Google Colab** | [s.itera.id/ipynb_Studio3-NLP_Kelompok11](https://s.itera.id/ipynb_Studio3-NLP_Kelompok11) | Notebook resmi (*Anyone with the link can view*) |
| **GitHub Repository** | [s.itera.id/Github_Studio3-NLP_Kelompok11](https://s.itera.id/Github_Studio3-NLP_Kelompok11) | Kode, data, berkas laporan PDF, dan dokumentasi |

---

## ❓ Tiga Pertanyaan Riset Wajib

Seluruh angka merujuk pada hasil evaluasi data uji resmi (500 kalimat) dari run konfigurasi `94fade` (rata-rata ± SD dari 3 seed acak: 42, 123, 2024).

### Q1. Backbone mana yang memberi trade-off akurasi-vs-efisiensi terbaik?
**IndoBERT (`indobenchmark/indobert-base-p1`).**
- **Performa & Biaya (Full Fine-Tuning):**
  - **IndoBERT:** Macro F1 **0,8942 ± 0,0130** | Akurasi **0,9193** | Waktu latih **111,8 s** | Latensi **8,51 ± 1,17 ms** | Parameter **124,4 jt** | Memori **2.998 MB**
  - **mBERT:** Macro F1 **0,7730 ± 0,0081** | Akurasi **0,8100** | Waktu latih **144,1 s** | Latensi **8,35 ± 0,86 ms** | Parameter **177,9 jt** | Memori **3.886 MB**
  - **DistilmBERT:** Macro F1 **0,7501 ± 0,0121** | Akurasi **0,7827** | Waktu latih **82,4 s** | Latensi **4,31 ± 0,67 ms** | Parameter **135,3 jt** | Memori **2.627 MB**
- **Analisis:**
  1. IndoBERT unggul mutlak atas mBERT: F1 lebih tinggi **+12,11 poin** ($p = 0,0005$), waktu latih **22,4% lebih cepat**, memori GPU **22,8% lebih hemat**, dan parameter 30% lebih sedikit.
  2. DistilmBERT memang memiliki latensi inferensi tercepat (4,31 ms vs 8,51 ms). Namun efisiensi 4,2 ms tersebut dibayar dengan anjloknya performa sebesar **-14,40 poin F1** (sekitar 11× simpangan baku antar-seed), serta recall kelas *neutral* yang jatuh ke 53,8% (vs 70,5% pada IndoBERT).
  3. Latensi 8,51 ms pada IndoBERT sudah setara kapasitas pemrosesan ~117 kalimat/detik (cukup untuk skenario *real-time*). Keunggulannya berasal dari korpus pre-training yang spesifik bahasa Indonesia (*in-domain*).

### Q2. Apakah strategi hemat komputasi (probing/partial) cukup kompetitif dibanding full fine-tuning?
**Hanya kompetitif pada arsitektur in-domain (IndoBERT), tetapi gagal pada model multilingual.**
- **Evaluasi terhadap simpangan baku antar-seed (SD maks = 1,30 poin):**
  - **IndoBERT Partial Freezing:** F1 **0,8901 ± 0,0074**, hanya tertinggal **0,41 poin** dari Full FT (lebih kecil dari SD 1,30 poin, $p = 0,67$ — secara statistik **setara/belum berbeda bermakna**). Strategi ini memangkas waktu latih **44,6%** (61,9 vs 111,8 s), memori GPU **46,2%** (1.614 vs 2.998 MB), dan melatih hanya 34,7% parameter.
  - **mBERT Partial Freezing:** Tertinggal **-6,75 poin** ($p < 0,001$, penurunan signifikan jauh melampaui variasi acak).
  - **DistilmBERT Partial Freezing:** Tertinggal **-8,34 poin** (bahkan jatuh ke F1 0,6668, di bawah baseline TF-IDF 0,6786).
  - **Linear Probing:** Menghemat komputasi 74–80%, namun F1 anjlok drastis di semua backbone (IndoBERT -11,15 poin; mBERT -32,03 poin; DistilmBERT -22,70 poin).
- **Kesimpulan:** Pembekuan representasi layer bawah hanya aman jika representasi fitur model sudah selaras dengan tata bahasa dan kosakata bahasa Indonesia. Pada model multibahasa, membekukan layer justru mematikan kapasitas adaptasi fitur.

### Q3. Kombinasi apa yang direkomendasikan, dan mengapa?
Berdasarkan kriteria kelolosan batas kewajaran, toleransi performa terhadap variasi seed, dan efisiensi terukur:
1. **Skenario A (Akurasi Utama):** **IndoBERT + Full Fine-Tuning** (Macro F1: **0,8942 ± 0,0130**, Akurasi: **0,9193**). Pilihan wajib saat kualitas klasifikasi menjadi prioritas mutlak tanpa batasan komputasi ketat.
2. **Skenario B (Anggaran Latih Terbatas) — Rekomendasi Utama:** **IndoBERT + Partial Freezing** (Macro F1: **0,8901 ± 0,0074**). F1 setara dengan Full FT (selisih 0,41 poin < SD 1,30), namun memangkas durasi pelatihan hampir separuh (61,9 detik) dan hemat memori 1,4 GB, memungkinkan *retraining* berkala pada infrastruktur GPU murah.
3. **Skenario C (Inferensi Cepat):** **IndoBERT + Full / Partial Freezing** (latensi identik: **8,51 ms/kalimat**). DistilmBERT ditolak pada skenario ini karena penalti performanya (-14,40 poin) melanggar batas toleransi maksimal 4,0 poin. DistilmBERT hanya disarankan bila sistem mewajibkan ambang keras latensi di bawah 5 ms dengan kompromi separuh ulasan netral salah terklasifikasi.

---

## 🔬 Desain Eksperimen

Matriks **27 run** = 3 backbone × 3 strategi × 3 seed.

### Backbone
- **`indobenchmark/indobert-base-p1`**: monolingual Indonesia, 12 lapis encoder (~124,4M parameter)
- **`bert-base-multilingual-cased`**: multilingual 104 bahasa, 12 lapis encoder (~177,9M parameter)
- **`distilbert-base-multilingual-cased`**: multilingual hasil distilasi, 6 lapis transformer (~135,3M parameter)

### Strategi Fine-Tuning
- **Full fine-tuning:** seluruh parameter dilatih (baseline strategi).
- **Partial freezing:** embedding dan separuh lapis awal dibekukan (6 lapis pada BERT/IndoBERT, 3 lapis pada DistilBERT).
- **Linear probing:** seluruh backbone dibekukan 100%, hanya bobot classification head baru yang dilatih.

Semua run memakai *head replacement* sesuai 3 kelas sentimen SmSA (*negative*, *neutral*, *positive*).

### Pembagian Data & Kebocoran
| Himpunan | Sumber | Jumlah | Peran |
|:---|:---|:---:|:---|
| Latih | subset berstrata dari `train_preprocess.tsv` bersih | 5.000 | melatih model (sama persis di seluruh 27 run) |
| Validasi | `valid_preprocess.tsv` resmi | 1.260 | **hanya** memilih checkpoint epoch terbaik |
| Uji | `test_preprocess.tsv` resmi | 500 | disentuh **sekali** per run; seluruh metrik final dilaporkan di sini |

Pembersihan data mentah: deteksi label konflik (0 baris), deduplikasi persis (67 baris), pembersihan kebocoran data terhadap validasi/uji (14 baris). Diperoleh 10.919 baris latih bersih sebelum dicuplik 5.000 sampel berstrata (`random_state = 0`).

### Variabel Terkendali yang Dikunci
| Hiperparameter | Nilai | Catatan |
|:---|:---|:---|
| Max sequence length | 128 token | mencakup distribusi panjang kalimat ulasan SmSA |
| Batch size | 32 | seragam untuk seluruh kombinasi |
| Epoch | maksimum 4 | checkpoint terbaik ditentukan oleh F1 makro validasi |
| Optimizer | AdamW (`weight_decay = 0.01`) | warmup linear 10% dilanjutkan linear decay |
| Learning rate | 3e-5 (full & partial), 3e-3 (probing) | probing membutuhkan lr lebih besar untuk konvergensi head |
| Presisi | FP16 (AMP) | percepatan komputasi GPU Tesla T4 |
| Seed | 42, 123, 2024 | dieksekusi identik di setiap kombinasi |
| Latensi inferensi | batch = 1, 300 kalimat, FP32 | diukur berurutan dalam satu sesi benchmark terkontrol |

---

## 📊 Hasil Eksperimen

Rata-rata ± simpangan baku 3 seed pada **data uji resmi** (kode konfigurasi `94fade`, Google Colab GPU Tesla T4).

| Backbone | Strategi | F1 makro | Akurasi | Waktu latih (s) | Memori puncak (MB) | Latensi (ms/kalimat) | Parameter dilatih |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| **IndoBERT** | **Full** | **0,8942 ± 0,0130** | **0,9193 ± 0,0061** | 111,8 | 2.998 | 8,51 ± 1,17 | 124,4 jt (100%) |
| IndoBERT | Partial | 0,8901 ± 0,0074 | 0,9167 ± 0,0050 | 61,9 | 1.614 | 8,51 ± 1,17 | 43,1 jt (34,7%) |
| IndoBERT | Probing | 0,7826 ± 0,0060 | 0,8247 ± 0,0070 | 28,9 | 601 | 8,51 ± 1,17 | 2.307 (<0,01%) |
| mBERT | Full | 0,7730 ± 0,0081 | 0,8100 ± 0,0122 | 144,1 | 3.886 | 8,35 ± 0,86 | 177,9 jt (100%) |
| mBERT | Partial | 0,7055 ± 0,0138 | 0,7333 ± 0,0130 | 79,2 | 1.958 | 8,35 ± 0,86 | 43,1 jt (24,2%) |
| mBERT | Probing | 0,4527 ± 0,0056 | 0,5353 ± 0,0064 | 37,4 | 828 | 8,35 ± 0,86 | 2.307 (<0,01%) |
| DistilmBERT | Full | 0,7501 ± 0,0121 | 0,7827 ± 0,0151 | 82,4 | 2.627 | 4,31 ± 0,67 | 135,3 jt (100%) |
| DistilmBERT | Partial | 0,6668 ± 0,0180 | 0,6907 ± 0,0200 | 37,6 | 1.181 | 4,31 ± 0,67 | 21,9 jt (16,2%) |
| DistilmBERT | Probing | 0,5231 ± 0,0026 | 0,5780 ± 0,0060 | 19,0 | 672 | 4,31 ± 0,67 | 592.899 (0,44%) |

*Pembanding Acuan:* Baseline TF-IDF + Logistic Regression (data latih penuh): F1 makro **0,6786**; Tebakan acak berstrata: **0,3054**; Kelas mayoritas (positif): **0,3007**.

**Ringkasan Status Hipotesis:**
- **H1 (Terdukung):** IndoBERT Full FT mengungguli mBERT (+12,11 poin, $p = 0,0005$) dan DistilmBERT (+14,40 poin, $p = 0,0002$), jauh melebihi simpangan acak antar-seed.
- **H2 (Terdukung):** DistilmBERT menghemat 42,8% waktu latih dan 48,4% latensi inferensi terhadap mBERT, dengan penurunan skor F1 sebesar 2,29 poin (di bawah ambang batas toleransi 3,0 poin).
- **H3 (Terdukung Bersyarat):** Hierarki Full $\ge$ Partial > Probing terbukti konsisten. Penghematan biaya komputasi $\ge 40\%$ tercapai di seluruh model. Namun retensi performa $\ge 96\%$ **hanya berhasil dicapai pada IndoBERT (99,5%)**, sedangkan mBERT (91,3%) dan DistilmBERT (88,9%) gagal mempertahankan performanya.

---

## 📁 Struktur Repositori

```text
studio3_Deep-Learning_NLP/
├── data/
│   ├── test_preprocess.tsv         # data uji resmi SmSA IndoNLU (500 kalimat)
│   ├── train_preprocess.tsv        # data latih resmi SmSA IndoNLU (11.000 kalimat mentah)
│   └── valid_preprocess.tsv        # data validasi resmi SmSA IndoNLU (1.260 kalimat)
├── hasil_eksperimen/               # berkas keluaran notebook (kode konfigurasi '94fade')
│   ├── baseline_tfidf_smsa_94fade.csv  # baseline TF-IDF & regresi logistik
│   ├── cek_kewajaran_smsa_94fade.csv   # pemeriksaan batas kewajaran metrik
│   ├── evaluasi_hipotesis_94fade.csv   # hasil evaluasi formal hipotesis H1, H2, H3
│   ├── grafik_1_akurasi_94fade.png     # perbandingan akurasi & Macro F1
│   ├── grafik_2_biaya_94fade.png       # perbandingan waktu latih & memori GPU puncak
│   ├── grafik_3_tradeoff_94fade.png    # scatter plot trade-off F1 vs latensi inferensi
│   ├── grafik_4_f1_per_kelas_94fade.png# perbandingan F1 per kelas (pos/neu/neg)
│   ├── grafik_5_confusion_full_94fade.png # confusion matrix 3 backbone mode Full
│   ├── grafik_6_confusion_semua_94fade.png# confusion matrix seluruh 9 kombinasi run
│   ├── hasil_smsa_94fade.csv           # log mentah 27 run eksperimen
│   ├── latensi_sesi_94fade.csv         # benchmark latensi satu sesi (300 kalimat)
│   ├── prediksi_smsa_94fade.csv        # prediksi data uji tiap run
│   ├── rekap_agregat_smsa_94fade.csv   # ringkasan mean ± std per kombinasi
│   ├── rekomendasi_smsa_94fade.csv     # ringkasan rekomendasi skenario A, B, C
│   └── subset_latih_smsa_94fade.csv    # 5.000 sampel data latih yang digunakan
├── laporan_dan_presentasi/
│   └── STUDIO3_Kelompok11_Sigit_Kurnia_Hartawan_Muhammad_Romadhon_Santoso.pdf # ekspor PDF notebook lengkap (42 halaman)
├── notebooks/
│   └── Studio_Proyek_3_NLP.ipynb       # notebook utama eksperimen (27 run, PyTorch & Transformers)
├── Soal_Studi_Kasus_Studio_Proyek_3.pdf # lembar soal & studi kasus studio 3
├── Spesifikasi_Tugas_Studio_Proyek_3.pdf # spesifikasi teknis tugas studio 3
└── README.md                           # dokumentasi eksperimen dan analisis
```

---

## 🚀 Panduan Menjalankan Eksperimen

1. Buka berkas [`notebooks/Studio_Proyek_3_NLP.ipynb`](notebooks/Studio_Proyek_3_NLP.ipynb) melalui **Google Colab** dengan runtime GPU Tesla T4.
2. Dataset akan diunduh dan dibersihkan secara otomatis. Seluruh artefak hasil akan disimpan otomatis ke `MyDrive/Studio3_NLP/output/`.
3. Mode Eksekusi:
   - **`MODE = "smoke"`**: Uji cepat alur pipeline kode (mini subset, 1 seed, 1 epoch) ke direktori terpisah.
   - **`MODE = "full"`**: Menjalankan matriks penuh 27 run (3 backbone × 3 strategi × 3 seed), menghasilkan evaluasi statistik, visualisasi grafik, dan tabel bukti Q1–Q3.

---

## 📚 Referensi

1. **SmSA & IndoNLU:** Wilie, B., dkk. (2020). *IndoNLU: Benchmark and Resources for Evaluating Indonesian Natural Language Understanding*. Proceedings of AACL-IJCNLP 2020.
2. **IndoBERT:** Koto, F., Rahimi, A., Lau, J. H., & Baldwin, T. (2020). *IndoLEM and IndoBERT: A Benchmark Dataset and Pre-trained Language Model for Indonesian NLP*. Proceedings of COLING 2020.
3. **mBERT:** Devlin, J., Chang, M. W., Lee, K., & Toutanova, K. (2019). *BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding*. Proceedings of NAACL-HLT 2019.
4. **DistilBERT:** Sanh, V., Debut, L., Chaumond, J., & Wolf, T. (2019). *DistilBERT, a distilled version of BERT: smaller, faster, cheaper and lighter*. NeurIPS EMC² Workshop.

---
*Studio Proyek 3 — Pembelajaran Mendalam (IF25-40401) | Teknik Informatika, Institut Teknologi Sumatera (ITERA).*
