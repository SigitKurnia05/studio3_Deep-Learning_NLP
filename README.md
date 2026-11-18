# Studio Proyek 3: Fine-Tuning Transformer Pretrained untuk Klasifikasi Sentimen Bahasa Indonesia (SmSA)

[![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)](https://www.python.org/)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.0%2B-EE4C2C.svg)](https://pytorch.org/)
[![HuggingFace](https://img.shields.io/badge/%F0%9F%A4%97-Transformers-yellow.svg)](https://huggingface.co/)
[![Dataset](https://img.shields.io/badge/Dataset-SmSA%20(IndoNLU)-green.svg)](https://github.com/indo-nlp/indonlu)
[![License](https://img.shields.io/badge/License-Academic-lightgrey.svg)]()

Repositori ini memuat implementasi, analisis komparatif, dan laporan eksperimen untuk **Studio Proyek 3 — Pembelajaran Mendalam (IF25-40401)**. Proyek ini membandingkan kinerja dan efisiensi komputasi dari 3 *backbone* model bahasa berbasis Transformer (*monolingual* vs *multilingual*) di bawah 3 strategi *fine-tuning* pada dataset klasifikasi sentimen Bahasa Indonesia (**SmSA - IndoNLU**).

---

## 👥 Tim Penyusun (Kelompok Yolo)

**Program Studi Teknik Informatika — Institut Teknologi Sumatera (ITERA)**

| Nama Anggota | NIM |
|:---|:---:|
| **Sigit Kurnia Hartawan** | `123140033` |
| **Muhammad Romadhon Santoso** | `123140031` |

---

## 📌 Latar Belakang & Masalah

Model Transformer berukuran besar sering kali menghasilkan akurasi tinggi pada tugas NLP, namun membutuhkan biaya komputasi yang masif (waktu pelatihan, konsumsi memori GPU, dan latensi inferensi). Pada skenario nyata di industri (analisis ulasan *e-commerce*, *brand sentiment monitoring*, sistem tiket *customer support*), performa model harus selalu dikompromikan dengan efisiensi operasional.

Proyek ini menjawab 3 pertanyaan riset utama:
1. **Keunggulan Domain Bahasa:** Sejauh mana model *monolingual* Bahasa Indonesia (`IndoBERT`) mengungguli model *multilingual* (`mBERT`, `DistilmBERT`), dan apakah perbedaannya melampaui variasi acak antar-seed?
2. **Efisiensi Model Kompresi:** Apakah `DistilmBERT` mampu memberikan penghematan komputasi yang signifikan (≥ 35%) dengan penurunan performa yang dapat ditoleransi (≤ 3 poin F1)?
3. **Strategi Pembekuan Lapisan (*Layer Freezing*):** Seberapa kompetitif strategi *Partial Freezing* dan *Linear Probing* dibandingkan *Full Fine-Tuning* dalam memangkas waktu latih dan konsumsi VRAM?

---

## 🔬 Desain Eksperimen

Eksperimen dirancang secara terkendali menggunakan **Matriks 27 Run** (3 Model × 3 Strategi × 3 Random Seed):

### 1. Model Backbone
- **`indobenchmark/indobert-base-p1`** (Monolingual Indonesia, 12 layer, ~124.4M parameter)
- **`bert-base-multilingual-cased`** (Multilingual 104 bahasa, 12 layer, ~177.9M parameter)
- **`distilbert-base-multilingual-cased`** (Distilled multilingual, 6 layer, ~135.3M parameter)

### 2. Strategi Fine-Tuning
- **Full Fine-Tuning:** Seluruh bobot *backbone* dan *classification head* dilatih (100% parameter *trainable*).
- **Partial Freezing:** *Embedding* dan separuh lapisan awal dibekukan (6 layer pertama pada BERT; 3 layer pertama pada DistilBERT).
- **Linear Probing:** Seluruh lapisan *backbone* dibekukan 100%, hanya bobot *classification head* yang dilatih.

### 3. Variabel Terkendali & Hiperparameter
| Hiperparameter | Nilai | Keterangan |
|:---|:---|:---|
| **Max Sequence Length** | `128` token | Mencakup mayoritas kalimat ulasan SmSA |
| **Batch Size** | `32` | Diseragamkan pada seluruh run |
| **Epochs** | `4` epoch | Tetap (tanpa early stopping) |
| **Optimizer** | `AdamW` (`weight_decay = 0.01`) | Standar fine-tuning Transformer |
| **Learning Rate** | `3e-5` (Full & Partial) / `1e-3` (Linear Probing) | Linear warmup (rasio 0.1) + Linear decay |
| **Presisi Komputasi** | FP16 (Automatic Mixed Precision / AMP) | Efisiensi komputasi pada GPU T4 |
| **Variasi Seed** | `42`, `123`, `2024` | Untuk mengukur *mean ± std* |
| **Dataset Evaluasi** | `valid_preprocess.tsv` (1.260 baris) | Pembagian resmi IndoNLU |

---

## 🧹 Pembersihan & Pra-pemrosesan Data (SmSA)

Dataset SmSA memiliki 3 label sentimen: `positive`, `negative`, dan `neutral`. Protokol pembersihan dilakukan secara ketat untuk mencegah kebocoran data (*data leakage*):
1. **Deteksi Label Bertentangan:** Memeriksa teks identik dengan label berbeda (ditemukan `0` konflik).
2. **Deduplikasi Teks Persis:** Membuang `67` baris duplikat identik pada data latih.
3. **Pembersihan Kebocoran Validasi:** Membuang `14` baris data latih yang memiliki teks identik dengan himpunan validasi.
4. **Hasil Akhir:** Data latih bersih berjumlah **10.919 baris** (dari 11.000 baris mentah).

> **Catatan Metrik:** Karena distribusi kelas tidak seimbang (`positive` 58.4%, `negative` 31.2%, `neutral` 10.4%), **Macro F1-Score** dijadikan metrik evaluasi primer, bukan akurasi.

---

## 📊 Hasil Eksperimen & Analisis

Berikut adalah ringkasan hasil agregat (*Mean ± Std* dari 3 seed independen):

| Backbone | Strategi | Akurasi | Macro F1 | F1 Neutral | Waktu Latih (s) | Latensi (ms/kalimat) | Peak GPU Mem (MB) | Parameter Dilatih |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **IndoBERT** | **Full** | **0.9407 ± 0.0048** | **0.9167 ± 0.0042** | **0.8594 ± 0.0030** | 217.16 ± 1.65 | 8.77 ± 1.62 | 3257.96 ± 3.34 | 124.4M (100%) |
| IndoBERT | Partial | 0.9349 ± 0.0008 | 0.9085 ± 0.0014 | 0.8477 ± 0.0043 | 121.80 ± 0.34 | 8.18 ± 1.16 | 1750.08 ± 2.11 | 43.1M (34.7%) |
| IndoBERT | Probing | 0.8865 ± 0.0016 | 0.8495 ± 0.0022 | 0.7742 ± 0.0066 | 55.29 ± 0.06 | 8.54 ± 1.55 | 582.23 ± 0.00 | 2.3K (0.002%) |
| **mBERT** | Full | 0.9148 ± 0.0091 | 0.8822 ± 0.0132 | 0.8110 ± 0.0235 | 287.71 ± 0.40 | 8.11 ± 0.83 | 3878.14 ± 15.59 | 177.9M (100%) |
| mBERT | Partial | 0.8841 ± 0.0060 | 0.8431 ± 0.0037 | 0.7574 ± 0.0046 | 147.77 ± 0.17 | 7.77 ± 0.28 | 1949.82 ± 4.13 | 43.1M (24.2%) |
| mBERT | Probing | 0.7519 ± 0.0012 | 0.6362 ± 0.0004 | 0.4093 ± 0.0069 | 69.89 ± 0.09 | 9.52 ± 0.75 | 786.23 ± 0.00 | 2.3K (0.001%) |
| **DistilmBERT** | Full | 0.9130 ± 0.0053 | 0.8767 ± 0.0031 | 0.7945 ± 0.0040 | 166.52 ± 0.25 | **4.65 ± 0.76** | 2618.73 ± 9.47 | 135.3M (100%) |
| DistilmBERT | Partial | 0.8669 ± 0.0017 | 0.8172 ± 0.0024 | 0.7095 ± 0.0135 | 72.54 ± 0.07 | 4.46 ± 0.99 | 1181.68 ± 5.78 | 21.9M (16.2%) |
| DistilmBERT | Probing | 0.8140 ± 0.0045 | 0.7529 ± 0.0055 | 0.6374 ± 0.0094 | **36.37 ± 0.16** | 4.40 ± 0.50 | **622.46 ± 0.00** | 592.9K (0.44%) |

### 📈 Evaluasi Hipotesis Penelitian

| Hipotesis | Pengujian & Klaim | Bukti Empiris | Status |
|:---:|:---|:---|:---:|
| **H1** | IndoBERT Full Fine-Tuning mengungguli mBERT & DistilmBERT secara signifikan | Selisih F1 vs mBERT: **+3.45 poin** ($p=0.0360$)<br>Selisih F1 vs DistilmBERT: **+4.00 poin** ($p=0.0003$) | **TERDUKUNG** |
| **H2** | DistilmBERT menghemat waktu latih & latensi $\ge 35\%$ vs mBERT dengan penurunan F1 $\le 3$ poin | Hemat waktu latih: **42.1%**<br>Hemat latensi inferensi: **42.6%**<br>Penurunan F1: hanya **0.55 poin** | **TERDUKUNG** |
| **H3** | Hierarki performa: Full $\ge$ Partial > Probing; Partial mempertahankan $\ge 96\%$ performa Full dengan penghematan biaya $\ge 40\%$ | Hierarki terbukti pada seluruh model.<br>Pada IndoBERT: Partial mencapai **99.1%** performa Full, hemat waktu **43.9%**, hemat memori **46.3%**. | **TERDUKUNG BERSYARAT**<br>*(Terpenuhi penuh di IndoBERT, mBERT & DistilmBERT di bawah 96%)* |

---

## 💡 Rekomendasi Penerapan di Industri

1. **Skenario Server / Akurasi Tertinggi (*High-Stakes Sentiment*):**
   - **Rekomendasi:** `IndoBERT Full Fine-Tuning`
   - **Alasan:** Macro F1 tertinggi (**91.67%**) dan F1 kelas neutral terbaik (**85.94%**), sangat cocok jika akurasi adalah prioritas mutlak.
2. **Skenario Pelatihan Berulang / Anggaran Terbatas (*Green AI / Fast Retraining*):**
   - **Rekomendasi:** `IndoBERT Partial Freezing`
   - **Alasan:** Mempertahankan 99.1% performa *full fine-tuning* (F1 **90.85%**) dengan waktu latih **43.9% lebih cepat** dan konsumsi memori GPU **46.3% lebih hemat**.
3. **Skenario Real-Time / Edge Deployment (*Low Latency Streaming*):**
   - **Rekomendasi:** `DistilmBERT Full Fine-Tuning`
   - **Alasan:** Latensi inferensi terpangkas hingga **4.65 ms/kalimat** (hampir 2× lipat lebih responsif dari BERT standar) dengan Macro F1 yang tetap kompetitif (**87.67%**).

---

## 📁 Struktur Repositori

```text
studio3_Deep-Learning_NLP/
├── data/
│   ├── train_preprocess.tsv       # Dataset latih resmi SmSA (IndoNLU)
│   └── valid_preprocess.tsv       # Dataset validasi resmi SmSA (IndoNLU)
├── hasil_eksperimen/
│   ├── evaluasi_hipotesis_8e43b7.csv   # Hasil uji statistik hipotesis H1, H2, H3
│   ├── rekap_agregat_smsa_8e43b7.csv   # Rekap mean ± std 27 run (9 kombinasi)
│   ├── hasil_smsa_8e43b7.csv           # Log mentah setiap run
│   ├── grafik_1_akurasi_8e43b7.png     # Grafik perbandingan akurasi & Macro F1
│   ├── grafik_2_biaya_8e43b7.png       # Grafik waktu latih & memori puncak
│   ├── grafik_3_tradeoff_8e43b7.png    # Grafik trade-off F1 vs Latensi inferensi
│   └── grafik_4_f1_per_kelas_8e43b7.png# Grafik perbandingan F1 per kelas sentimen
├── laporan_dan_presentasi/
│   ├── Laporan_Singkat_Template.md     # Template laporan singkat resmi 4 halaman
│   ├── Outline_Slide_Presentasi.md     # Rencana alur 15 slide presentasi
│   └── STUDIO3_KelompokYolo_Sigit_Kurnia_Hartawan_Muhammad_Romadhon_Santoso.pdf # Laporan akhir
├── notebooks/
│   └── Studio_Proyek_3_NLP.ipynb       # Jupyter Notebook lengkap (27 run + visualisasi)
├── Spesifikasi_Tugas_Studio_Proyek_3.pdf # Panduan & rubrik tugas Studio 3
└── README.md                           # Dokumentasi utama proyek
```

---

## 🚀 Panduan Menjalankan Eksperimen

### 1. Prasyarat Lingkungan
Pastikan Anda menggunakan Python 3.8+ dengan GPU (disarankan GPU NVIDIA dengan CUDA, minimal 8 GB VRAM seperti NVIDIA T4 di Colab).

Pasang dependensi yang dibutuhkan:
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install transformers scikit-learn pandas numpy matplotlib seaborn scipy
```

### 2. Menjalankan Notebook
Buka dan jalankan berkas [`Studio_Proyek_3_NLP.ipynb`](notebooks/Studio_Proyek_3_NLP.ipynb) melalui **Google Colab** atau **Jupyter Lab**:
- **Smoke Mode (`MODE = "smoke"`):** Digunakan untuk verifikasi cepat alur kode (1 seed, 1 epoch, subset data kecil).
- **Full Mode (`MODE = "full"`):** Menjalankan matriks penuh 27 run (3 model × 3 strategi × 3 seed × 4 epoch) dan menghasilkan rekapitulasi berkas CSV serta visualisasi grafik otomatis.

---

## 📚 Referensi

1. **IndoNLU / SmSA:** Wilie, B., et al. (2020). *IndoNLU: Benchmark and Resources for Evaluating Indonesian Natural Language Understanding*. Proceedings of AACL-IJCNLP 2020.
2. **IndoBERT:** Koto, F., Rahimi, A., Lau, J. H., & Baldwin, T. (2020). *IndoLEM and IndoBERT: A Benchmark Dataset and Pre-trained Language Model for Indonesian NLP*. COLING 2020.
3. **mBERT:** Devlin, J., Chang, M. W., Lee, K., & Toutanova, K. (2019). *BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding*. NAACL-HLT 2019.
4. **DistilBERT:** Sanh, V., Debut, L., Chaumond, J., & Wolf, T. (2019). *DistilBERT, a distilled version of BERT: smaller, faster, cheaper and lighter*. NeurIPS EMC^2 Workshop.

---
*Dikembangkan untuk pemenuhan tugas akademik Studio Proyek 3 — Pembelajaran Mendalam, Teknik Informatika ITERA.*
