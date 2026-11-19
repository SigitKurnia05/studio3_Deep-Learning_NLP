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
| **Google Colab** | [s.itera.id/Colab_Studio3-NLP_Kelompok11](https://s.itera.id/Colab_Studio3-NLP_Kelompok11) | Notebook (akses *Anyone with the link can view*) |
| **GitHub Repository** | [s.itera.id/Github_Studio3-NLP_Kelompok11](https://s.itera.id/Github_Studio3-NLP_Kelompok11) | Kode, data, dan hasil eksperimen |

---

## ❓ Tiga Pertanyaan Riset Wajib

1. **Q1:** Backbone mana yang memberi *trade-off* akurasi-vs-efisiensi terbaik untuk klasifikasi sentimen ini?
2. **Q2:** Apakah strategi hemat komputasi (*linear probing* / *partial freezing*) cukup kompetitif dibanding *full fine-tuning*?
3. **Q3:** Kombinasi apa yang direkomendasikan, dan mengapa?

Jawaban lengkap beserta tabel buktinya ada di bagian 15 notebook.

---

## 🔬 Desain Eksperimen

Matriks **27 run** = 3 backbone × 3 strategi × 3 seed.

### Backbone
- **`indobenchmark/indobert-base-p1`**: monolingual Indonesia, 12 lapis
- **`bert-base-multilingual-cased`**: multilingual, 12 lapis
- **`distilbert-base-multilingual-cased`**: multilingual hasil distilasi, 6 lapis

### Strategi Fine-Tuning
- **Full fine-tuning:** seluruh parameter dilatih (baseline).
- **Partial freezing:** embedding dan separuh lapis awal dibekukan (6 lapis pada BERT, 3 lapis pada DistilBERT).
- **Linear probing:** seluruh backbone dibekukan, hanya head klasifikasi yang dilatih.

Semua run memakai *head replacement* (head baru 3 kelas).

### Pembagian Data
| Himpunan | Sumber | Jumlah | Peran |
|:---|:---|:---:|:---|
| Latih | subset berstrata dari `train_preprocess.tsv` yang sudah dibersihkan | 5.000 | melatih model (sama untuk semua run) |
| Validasi | `valid_preprocess.tsv` resmi | 1.260 | **hanya** memilih epoch terbaik |
| Uji | `test_preprocess.tsv` resmi | 500 | disentuh **sekali** per run; semua metrik dilaporkan di sini |

Pembersihan data latih: label konflik → duplikat persis → kebocoran ke validasi/uji (0 konflik, 67 duplikat, 14 bocor; 10.919 baris bersih
sebelum diambil subset).

### Variabel Terkendali
| Hiperparameter | Nilai |
|:---|:---|
| Max sequence length | 128 token |
| Batch size | 32 |
| Epoch | maksimum 4, epoch terbaik dipilih dari F1 makro validasi |
| Optimizer | AdamW (`weight_decay = 0.01`), warmup linear 10% lalu linear decay |
| Learning rate | 3e-5 (full & partial), 3e-3 (linear probing) |
| Presisi | FP16 (AMP) |
| Seed | 42, 123, 2024 |
| Latensi inferensi | batch = 1, 300 kalimat, FP32, ketiga backbone diukur dalam satu sesi |

### Pembanding
Baseline TF-IDF + regresi logistik, tebakan acak (F1 makro ≈ 0,33), dan simpangan baku antar-seed. Metrik utama adalah **F1 makro**
karena kelas *neutral* minoritas di data latih (~10%) tetapi porsinya ~18% di data uji.

---

## 📊 Hasil Eksperimen

Rata-rata ± simpangan baku 3 seed pada **data uji resmi** (kode konfigurasi `94fade`, satu sesi Colab, Tesla T4).
Latensi diukur pada benchmark satu sesi dan hanya bergantung pada arsitektur backbone.

| Backbone | Strategi | F1 makro | Akurasi | Waktu latih (s) | Memori puncak (MB) | Latensi (ms/kalimat) | Parameter dilatih |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| **IndoBERT** | **Full** | **0,8942 ± 0,0130** | **0,9193 ± 0,0061** | 111,8 | 2.998 | 8,51 ± 1,17 | 124,4 jt (100%) |
| IndoBERT | Partial | 0,8901 ± 0,0074 | 0,9167 ± 0,0050 | 61,9 | 1.614 | 8,51 ± 1,17 | 43,1 jt (34,7%) |
| IndoBERT | Probing | 0,7826 ± 0,0060 | 0,8247 ± 0,0070 | 28,9 | 601 | 8,51 ± 1,17 | 2.307 |
| mBERT | Full | 0,7730 ± 0,0081 | 0,8100 ± 0,0122 | 144,1 | 3.886 | 8,35 ± 0,86 | 177,9 jt (100%) |
| mBERT | Partial | 0,7055 ± 0,0138 | 0,7333 ± 0,0130 | 79,2 | 1.958 | 8,35 ± 0,86 | 43,1 jt (24,2%) |
| mBERT | Probing | 0,4527 ± 0,0056 | 0,5353 ± 0,0064 | 37,4 | 828 | 8,35 ± 0,86 | 2.307 |
| DistilmBERT | Full | 0,7501 ± 0,0121 | 0,7827 ± 0,0151 | 82,4 | 2.627 | 4,31 ± 0,67 | 135,3 jt (100%) |
| DistilmBERT | Partial | 0,6668 ± 0,0180 | 0,6907 ± 0,0200 | 37,6 | 1.181 | 4,31 ± 0,67 | 21,9 jt (16,2%) |
| DistilmBERT | Probing | 0,5231 ± 0,0026 | 0,5780 ± 0,0060 | 19,0 | 672 | 4,31 ± 0,67 | 592.899 |

Pembanding: baseline TF-IDF + regresi logistik (data latih penuh) F1 makro **0,6786**, dan tebakan acak berstrata **0,3054**.

**Ringkasan temuan**
- **H1 terdukung:** IndoBERT unggul +12,11 poin atas mBERT dan +14,40 poin atas DistilmBERT, jauh di atas simpangan antar-seed (≤ 1,30 poin).
- **H2 terdukung:** DistilmBERT menghemat waktu latih 42,8% dan latensi 48,4% terhadap mBERT, dengan penurunan F1 2,29 poin.
- **H3 hanya terdukung pada IndoBERT:** partial freezing mempertahankan 99,5% F1 full pada IndoBERT, tetapi hanya 91,3% (mBERT) dan 88,9% (DistilmBERT).
- **Rekomendasi:** **IndoBERT + partial freezing**. F1-nya belum beda dari full fine-tuning (selisih 0,41 < SD 1,30 poin), dengan waktu latih
  44,6% lebih singkat dan memori GPU 46,2% lebih kecil.

Pembahasan lengkap, pemeriksaan kewajaran, dan jawaban Q1–Q3 ada di bagian 14–15 notebook.

---

## 📁 Struktur Repositori

```text
studio3_Deep-Learning_NLP/
├── data/
│   ├── train_preprocess.tsv        # data latih resmi SmSA (IndoNLU)
│   ├── valid_preprocess.tsv        # data validasi resmi
│   └── test_preprocess.tsv         # data uji resmi (500 kalimat)
├── hasil_eksperimen/               # salinan berkas keluaran notebook (CSV dan grafik, berkode konfigurasi)
├── laporan_dan_presentasi/         # PDF notebook: STUDIO3_Kelompok11_<Anggota1>_<Anggota2>.pdf
├── notebooks/
│   └── Studio_Proyek_3_NLP.ipynb   # notebook lengkap (27 run, analisis, visualisasi)
├── Spesifikasi_Tugas_Studio_Proyek_3.pdf
├── Soal_Studi_Kasus_Studio_Proyek_3.pdf
└── README.md
```

---

## 🚀 Menjalankan Eksperimen

Buka [`notebooks/Studio_Proyek_3_NLP.ipynb`](notebooks/Studio_Proyek_3_NLP.ipynb) di Google Colab dengan GPU T4. Data diunduh otomatis,
dan seluruh keluaran disimpan ke `MyDrive/Studio3_NLP/output/` agar dapat dilanjutkan bila sesi terputus.

- **`MODE = "smoke"`**: uji cepat alur kode (subset kecil, 1 seed, 1 epoch) ke folder terpisah.
- **`MODE = "full"`**: matriks penuh 27 run beserta rekap, grafik, evaluasi hipotesis, dan tabel bukti Q1–Q3.

---

## 📚 Referensi

1. Wilie, B., dkk. (2020). *IndoNLU: Benchmark and Resources for Evaluating Indonesian Natural Language Understanding*. AACL-IJCNLP 2020.
   (sumber dataset SmSA dan model `indobenchmark/indobert-base-p1`)
2. Devlin, J., Chang, M.-W., Lee, K., & Toutanova, K. (2019). *BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding*. NAACL-HLT 2019.
3. Sanh, V., Debut, L., Chaumond, J., & Wolf, T. (2019). *DistilBERT, a distilled version of BERT: smaller, faster, cheaper and lighter*. NeurIPS EMC² Workshop.

---
*Dikembangkan untuk pemenuhan tugas akademik Studio Proyek 3 — Pembelajaran Mendalam, Teknik Informatika ITERA.*
