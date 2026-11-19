# Studio Proyek 3: Fine-Tuning Transformer Pretrained untuk Klasifikasi Sentimen Bahasa Indonesia (SmSA)

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.x-EE4C2C.svg)](https://pytorch.org/)
[![HuggingFace](https://img.shields.io/badge/%F0%9F%A4%97-Transformers-yellow.svg)](https://huggingface.co/)
[![Dataset](https://img.shields.io/badge/Dataset-SmSA%20(IndoNLU)-green.svg)](https://github.com/indobenchmark/indonlu)

Repositori ini memuat implementasi, analisis komparatif, dan laporan eksperimen untuk **Studio Proyek 3 — Pembelajaran Mendalam (IF25-40401)**. Proyek ini membandingkan kinerja dan efisiensi komputasi dari 3 model bahasa berbasis Transformer (*monolingual* Indonesia vs *multilingual*) di bawah 3 strategi *fine-tuning* pada dataset klasifikasi sentimen Bahasa Indonesia (**SmSA - IndoNLU**). 

Tujuan evaluasi adalah mengukur *trade-off* nyata antara skor Macro F1, waktu pelatihan, latensi inferensi, dan konsumsi memori GPU untuk menghasilkan rekomendasi berbasis data empiris.

---

## 👥 Tim Penyusun (Kelompok 11 - Yolo)

**Program Studi Teknik Informatika — Institut Teknologi Sumatera (ITERA)**

| Nama Anggota | NIM | Peran Utama |
|:---|:---:|:---|
| **Sigit Kurnia Hartawan** | `123140033` | Implementasi model, pipeline training Colab, dan visualisasi metrik |
| **Muhammad Romadhon Santoso** | `123140031` | Desain eksperimen, analisis statistik, validasi hipotesis, dan dokumentasi |

---

## 🔗 Tautan Akses Proyek

| Sumber Daya | Tautan Akses | Keterangan |
|:---|:---|:---|
| **Google Drive** | [s.itera.id/Drive_Studio3-NLP_Kelompok11](https://s.itera.id/Drive_Studio3-NLP_Kelompok11) | Direktori output lengkap: CSV run, grafik visualisasi, dan checkpoint |
| **Google Colab** | [s.itera.id/ipynb_Studio3-NLP_Kelompok11](https://s.itera.id/ipynb_Studio3-NLP_Kelompok11) | Notebook interaktif GPU T4 (*Anyone with the link can view*) |
| **GitHub Repository** | [s.itera.id/Github_Studio3-NLP_Kelompok11](https://s.itera.id/Github_Studio3-NLP_Kelompok11) | Kode sumber, kurasi data, log hasil eksperimen, dan laporan |

---

## 🔬 Desain Eksperimen Sistematis

Eksperimen dirancang secara terkendali menggunakan **Matriks 27 Run** (3 Model Backbone × 3 Strategi Fine-Tuning × 3 Random Seed):

### 1. Model Backbone
- **`indobenchmark/indobert-base-p1`** (Monolingual Indonesia, 12 lapis encoder, ~124.4M parameter).
- **`bert-base-multilingual-cased`** (Multilingual 104 bahasa, 12 lapis encoder, ~177.9M parameter).
- **`distilbert-base-multilingual-cased`** (Distilled multilingual, 6 lapis transformer, ~135.3M parameter).

### 2. Strategi Fine-Tuning
Seluruh konfigurasi menerapkan **head replacement** (mengganti classifier bawaan sesuai 3 kelas sentimen SmSA).
- **Full Fine-Tuning:** Seluruh bobot parameter backbone dan classification head dilatih (100% parameter *trainable*). Menjadi baseline strategi.
- **Partial Freezing:** Lapisan embedding dan separuh lapisan awal dibekukan (6 lapis pertama pada BERT/IndoBERT; 3 lapis pertama pada DistilBERT). Hanya separuh lapis atas dan head klasifikasi yang diperbarui.
- **Linear Probing:** Seluruh lapisan backbone (embedding dan seluruh encoder) dibekukan 100%. Hanya bobot classification head baru yang dilatih.

### 3. Pembagian & Pra-pemrosesan Data (SmSA IndoNLU)
Pembersihan data dilakukan dengan urutan ketat untuk mencegah kebocoran data (*data leakage*):
1. **Deteksi Label Konflik:** Memeriksa kalimat sama dengan label bertentangan (ditemukan `0` konflik).
2. **Deduplikasi Persis:** Menghapus `67` baris duplikat identik pada data latih mentah.
3. **Pembersihan Kebocoran Data:** Menghapus `14` baris data latih yang identik dengan data validasi/uji.
4. **Hasil Bersih Awal:** Diperoleh 10.919 baris latih bersih (dari 11.000 baris mentah).

Sesuai ketentuan spesifikasi tugas studio:
- **Data Latih (Subset):** Dicuplik **5.000 sampel** secara berstrata (`random_state = 0`) agar representasi kelas seimbang dan seluruh run selesai dalam batas waktu komputasi.
- **Data Validasi:** **1.246 sampel** resmi (bersih), digunakan **hanya untuk memilih checkpoint epoch terbaik**.
- **Data Uji:** **500 sampel resmi SmSA** (`test_preprocess.tsv`), disentuh **hanya 1 kali per run** untuk evaluasi performa akhir.

### 4. Variabel Terkendali & Hiperparameter
| Variabel | Nilai Terkunci | Keterangan |
|:---|:---|:---|
| **Max Sequence Length** | `128` token | Mencakup seluruh panjang kalimat ulasan pada dataset SmSA |
| **Batch Size** | `32` | Diseragamkan pada seluruh kombinasi model dan strategi |
| **Jumlah Epoch** | `4` epoch | Epoch terbaik dipilih berdasarkan Macro F1 pada set validasi |
| **Optimizer** | `AdamW` (`weight_decay = 0.01`) | Standar optimasi fine-tuning Transformer |
| **Learning Rate** | `3e-5` (Full & Partial) / `3e-3` (Linear Probing) | Linear warmup 10% diikuti linear decay. Probing butuh lr lebih tinggi |
| **Presisi Komputasi** | FP16 (Automatic Mixed Precision / AMP) | Dijalankan pada Google Colab dengan GPU NVIDIA Tesla T4 |
| **Variasi Seed** | `42`, `123`, `2024` | Diuji 3 kali untuk melaporkan rata-rata ± simpangan baku (*Mean ± SD*) |
| **Benchmark Latensi** | Batch = 1, 300 sampel, FP32 | Ketiga backbone diukur dalam satu sesi komputasi yang identik |

---

## 📊 Rekapitulasi Hasil Eksperimen

Berikut adalah hasil rekapitulasi agregat (*Mean ± SD* dari 3 seed independen) pada **data uji resmi SmSA (500 kalimat)** dengan kode konfigurasi **`94fade`**:

| Backbone | Strategi | Akurasi | Macro F1 | F1 Neutral | Waktu Latih (s) | Memori GPU (MB) | Latensi (ms/kalimat) | Parameter Dilatih |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **IndoBERT** | **Full** | **0.9193 ± 0.0061** | **0.8942 ± 0.0130** | **0.7812 ± 0.0381** | 111.8 ± 6.3 | 2998.4 ± 0.0 | 8.51 ± 1.17 | 124.4M (100.0%) |
| IndoBERT | Partial | 0.9167 ± 0.0050 | 0.8901 ± 0.0074 | 0.7715 ± 0.0210 | 61.9 ± 0.2 | 1613.8 ± 0.0 | 8.51 ± 1.17 | 43.1M (34.7%) |
| IndoBERT | Probing | 0.8247 ± 0.0070 | 0.7826 ± 0.0060 | 0.5878 ± 0.0245 | 28.9 ± 0.1 | 601.2 ± 0.0 | 8.51 ± 1.17 | 2.3K (0.002%) |
| **mBERT** | Full | 0.8100 ± 0.0122 | 0.7730 ± 0.0081 | 0.6015 ± 0.0219 | 144.1 ± 2.6 | 3886.0 ± 0.0 | 8.35 ± 0.86 | 177.9M (100.0%) |
| mBERT | Partial | 0.7333 ± 0.0130 | 0.7055 ± 0.0138 | 0.5284 ± 0.0270 | 79.2 ± 4.3 | 1957.8 ± 0.0 | 8.35 ± 0.86 | 43.1M (24.2%) |
| mBERT | Probing | 0.5353 ± 0.0064 | 0.4527 ± 0.0056 | 0.2486 ± 0.0180 | 37.4 ± 0.5 | 827.6 ± 0.0 | 8.35 ± 0.86 | 2.3K (0.001%) |
| **DistilmBERT** | Full | 0.7827 ± 0.0151 | 0.7501 ± 0.0121 | 0.5732 ± 0.0335 | 82.4 ± 0.5 | 2626.9 ± 0.0 | **4.31 ± 0.67** | 135.3M (100.0%) |
| DistilmBERT | Partial | 0.6907 ± 0.0200 | 0.6668 ± 0.0180 | 0.4907 ± 0.0380 | 37.6 ± 0.1 | 1180.6 ± 0.0 | **4.31 ± 0.67** | 21.9M (16.2%) |
| DistilmBERT | Probing | 0.5780 ± 0.0060 | 0.5231 ± 0.0026 | 0.3204 ± 0.0210 | **19.0 ± 0.7** | **672.1 ± 0.0** | **4.31 ± 0.67** | 592.9K (0.44%) |

*Pembanding Sah:* Baseline TF-IDF + Logistic Regression (latih penuh) meraih Macro F1 **0.6786**, sedangkan tebakan acak terstratifikasi menghasilkan Macro F1 **0.3054**.

---

## 🎯 Pembahasan Tiga Pertanyaan Riset Wajib

### Q1. Backbone mana yang memberi trade-off akurasi-vs-efisiensi terbaik?

**Jawaban:** **IndoBERT (`indobenchmark/indobert-base-p1`)** memberikan trade-off akurasi dan efisiensi terbaik secara menyeluruh.

| Backbone | Macro F1 ± SD | Akurasi | Waktu Latih (s) | Latensi (ms/kalimat) | Parameter Total | Peak Memori (MB) |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| **IndoBERT** | **0.8942 ± 0.0130** | **0.9193** | 111.8 s | 8.51 ± 1.17 ms | 124.4M | 2.998 MB |
| **mBERT** | 0.7730 ± 0.0081 | 0.8100 | 144.1 s | 8.35 ± 0.86 ms | 177.9M | 3.886 MB |
| **DistilmBERT** | 0.7501 ± 0.0121 | 0.7827 | **82.4 s** | **4.31 ± 0.67 ms** | 135.3M | 2.627 MB |

**Analisis:**
1. **Keunggulan Akurasi:** IndoBERT mengungguli mBERT sebesar **+12.11 poin** ($p = 0.0005$) dan mengungguli DistilmBERT sebesar **+14.40 poin** ($p = 0.0002$). Selisih ini sekitar 10× lipat lebih besar dibanding simpangan baku antar-seed maksimum (1.30 poin), membuktikan bahwa keunggulan IndoBERT murni berasal dari kecocokan domain bahasa (*monolingual Indonesian corpus*), bukan variasi acak seed.
2. **Efisiensi Komputasi:** IndoBERT melatih parameter 30% lebih sedikit daripada mBERT (124.4M vs 177.9M) karena tidak dibebani ukuran kosakata multibahasa yang besar. Akibatnya, IndoBERT **22.4% lebih cepat dilatih** (111.8s vs 144.1s) dan **22.8% lebih hemat memori GPU** (2.998 MB vs 3.886 MB) dibanding mBERT.
3. **Trade-off Latensi:** DistilmBERT memang memiliki latensi inferensi tercepat (4.31 ms vs 8.51 ms pada IndoBERT). Namun, efisiensi waktu 4.2 ms tersebut harus dibayar dengan penurunan performa yang drastis (-14.40 poin F1). Untuk sistem nyata, latensi 8.51 ms sudah setara ~117 prediksi per detik secara sekuensial, sehingga IndoBERT tetap menjadi pemenang trade-off rasional.

---

### Q2. Apakah strategi hemat komputasi (probing/partial) cukup kompetitif dibanding full fine-tuning?

**Jawaban:** **Hanya kompetitif pada IndoBERT, namun GAGAL bersaing pada model multilingual (mBERT dan DistilmBERT).**

| Backbone | Strategi | Macro F1 ± SD | Tertinggal dari Full | SD Maks Antar-Seed | Kesimpulan Statistik | Hemat Latih | Hemat Memori | vs TF-IDF |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **IndoBERT** | **Partial** | 0.8901 ± 0.0074 | **0.41 poin** | 1.30 poin | **Setara (Belum Beda)** | **44.6%** | **46.2%** | +21.15 poin |
| IndoBERT | Probing | 0.7826 ± 0.0060 | 11.15 poin | 1.30 poin | Beda Bermakna | 74.2% | 80.0% | +10.40 poin |
| **mBERT** | Partial | 0.7055 ± 0.0138 | 6.75 poin | 1.38 poin | Beda Bermakna | 45.1% | 49.6% | +2.69 poin |
| mBERT | Probing | 0.4527 ± 0.0056 | 32.03 poin | 0.81 poin | Beda Bermakna | 74.1% | 78.7% | **-22.59 poin** |
| **DistilmBERT** | Partial | 0.6668 ± 0.0180 | 8.34 poin | 1.80 poin | Beda Bermakna | 54.4% | 55.1% | **-1.18 poin** |
| DistilmBERT | Probing | 0.5231 ± 0.0026 | 22.70 poin | 1.21 poin | Beda Bermakna | 76.9% | 74.4% | **-15.55 poin** |

**Analisis Teknis:**
- **IndoBERT Partial Freezing:** Mempertahankan **99.5% performa Full Fine-Tuning**. Selisih 0.41 poin berada di bawah simpangan antar-seed (1.30 poin, $p = 0.67$), yang berarti tidak berbeda secara signifikan. Namun, komputasi pelatihan terpangkas **44.6%** dan memori GPU terpangkas **46.2%** hanya dengan melatih 34.65% parameter.
- **Model Multilingual:** Pada mBERT dan DistilmBERT, membekukan lapisan awal menyebabkan penurunan F1 yang signifikan (beda bermakna). Bahkan pada Linear Probing, F1 makro mBERT (0.4527) dan DistilmBERT (0.5231) anjlok jauh di bawah baseline TF-IDF (0.6786).
- **Penyebab:** Bobot awal IndoBERT sudah merefleksikan fitur leksikal dan sintaksis bahasa Indonesia secara mendalam pada 6 lapisan awalnya. Sementara itu, representasi model multibahasa masih bersifat umum (dibagi ke 104 bahasa), sehingga memerlukan Full Fine-Tuning pada seluruh lapisan untuk beradaptasi terhadap karakteristik teks ulasan bahasa Indonesia.

---

### Q3. Kombinasi apa yang akan Anda rekomendasikan, dan mengapa?

Berdasarkan batas kriteria kelayakan teknis (status wajar di atas TF-IDF 0.6786, toleransi penurunan F1 ≤ 2.0 poin untuk skenario anggaran latih dan ≤ 4.0 poin untuk skenario inferensi cepat):

| Skenario | Rekomendasi Terpilih | Macro F1 ± SD | Waktu Latih | Memori GPU | Latensi Inferensi | Rasional Keputusan |
|:---|:---|:---:|:---:|:---:|:---:|:---|
| **A. Akurasi Utama** | **IndoBERT + Full Fine-Tuning** | **0.8942 ± 0.0130** | 111.8 s | 2.998 MB | 8.51 ms | Akurasi tertinggi (0.9193) dan F1 netral terbaik (0.7812). Wajib untuk skenario sensitif kesalahan (misal: analisis sentimen opini hukum atau eskalasi komplain darurat). |
| **B. Anggaran Latih Terbatas** | **IndoBERT + Partial Freezing** *(Rekomendasi Utama)* | **0.8901 ± 0.0074** | **61.9 s** | **1.614 MB** | 8.51 ms | **Pilihan paling optimal di industri.** Menjaga akurasi setara Full FT (selisih hanya 0.41 poin), namun waktu latih 44.6% lebih singkat dan memori 46.2% lebih kecil, sangat hemat biaya untuk pipeline pelatihan berkala (*continuous retraining*). |
| **C. Inferensi Cepat** | **IndoBERT + Full Fine-Tuning** (atau **Partial**) | 0.8942 ± 0.0130 | 111.8 s | 2.998 MB | 8.51 ms | DistilmBERT tidak dipilih karena F1-nya turun 14.40 poin (jauh di luar batas toleransi 4.0 poin). Latensi IndoBERT 8.51 ms sudah memadai untuk melayani ~117 req/detik per worker GPU pada sistem produksi. |

---

## 📈 Evaluasi Hipotesis Penelitian

| Hipotesis | Pengujian & Klaim Desain | Bukti Empiris Terukur | Status |
|:---:|:---|:---|:---:|
| **H1** | IndoBERT Full Fine-Tuning mengungguli mBERT dan DistilmBERT secara signifikan | Selisih F1 vs mBERT: **+12.11 poin** ($p = 0.0005$)<br>Selisih F1 vs DistilmBERT: **+14.40 poin** ($p = 0.0002$)<br>Selisih jauh melampaui simpangan baku maksimum (1.30 poin) | **TERDUKUNG** |
| **H2** | DistilmBERT menghemat waktu latih & latensi $\ge 35\%$ vs mBERT dengan penurunan F1 $\le 3$ poin | Penghematan waktu latih: **42.8%** (144.1s → 82.4s)<br>Penghematan latensi: **48.4%** (8.35ms → 4.31ms)<br>Penurunan Macro F1: hanya **2.29 poin** (di bawah batas 3.0 poin) | **TERDUKUNG** |
| **H3** | Hierarki performa: Full $\ge$ Partial > Probing; Partial mempertahankan $\ge 96\%$ performa Full dengan penghematan biaya komputasi $\ge 40\%$ | Hierarki performa terbukti konsisten pada seluruh model.<br>Penghematan waktu latih (44.6%–54.4%) dan memori (46.2%–55.1%) melampaui 40%.<br>Namun retensi performa $\ge 96\%$ **hanya tercapai pada IndoBERT (99.5%)**, sedangkan mBERT (91.3%) dan DistilmBERT (88.9%) gagal. | **TERDUKUNG BERSYARAT** *(Hanya valid pada arsitektur monolingual)* |

---

## 📁 Struktur Repositori

```text
studio3_Deep-Learning_NLP/
├── data/
│   ├── train_preprocess.tsv       # Dataset latih mentah resmi SmSA IndoNLU (11.000 baris)
│   ├── valid_preprocess.tsv       # Dataset validasi resmi SmSA IndoNLU (1.260 baris)
│   └── test_preprocess.tsv        # Dataset uji resmi SmSA IndoNLU (500 baris)
├── hasil_eksperimen/              # Berkas keluaran notebook kode '94fade'
│   ├── baseline_tfidf_smsa_94fade.csv  # Hasil baseline TF-IDF & Logistic Regression
│   ├── cek_kewajaran_smsa_94fade.csv   # Sanity check terhadap batas kewajaran
│   ├── evaluasi_hipotesis_94fade.csv   # Pengujian statistik formal H1, H2, H3
│   ├── grafik_1_akurasi_94fade.png     # Grafik batang perbandingan akurasi & Macro F1
│   ├── grafik_2_biaya_94fade.png       # Grafik waktu latih & konsumsi memori GPU
│   ├── grafik_3_tradeoff_94fade.png    # Scatter plot trade-off F1 vs Latensi inferensi
│   ├── grafik_4_f1_per_kelas_94fade.png# Perbandingan F1 per kelas (positive, neutral, negative)
│   ├── grafik_5_confusion_full_94fade.png # Confusion matrix 3 backbone mode Full
│   ├── grafik_6_confusion_semua_94fade.png# Confusion matrix lengkap 9 kombinasi run
│   ├── hasil_smsa_94fade.csv           # Log mentah per run (27 baris)
│   ├── latensi_sesi_94fade.csv         # Hasil benchmark latensi inferensi satu sesi
│   ├── rekap_agregat_smsa_94fade.csv   # Rekapitulasi rata-rata ± simpangan baku
│   ├── rekomendasi_smsa_94fade.csv     # Matriks rekomendasi skenario A, B, C
│   └── subset_latih_smsa_94fade.csv    # Salinan 5.000 teks latih subset yang digunakan
├── laporan_dan_presentasi/
│   └── STUDIO3_Kelompok11_Sigit_Kurnia_Hartawan_Muhammad_Romadhon_Santoso.pdf # Ekspor notebook PDF lengkap
├── notebooks/
│   └── Studio_Proyek_3_NLP.ipynb       # Notebook utama (27 run, pengujian terkunci, visualisasi)
├── Soal_Studi_Kasus_Studio_Proyek_3.pdf # Panduan soal dan rubrik presentasi
├── Spesifikasi_Tugas_Studio_Proyek_3.pdf # Spesifikasi teknis tugas studio 3
└── README.md                           # Dokumentasi komprehensif proyek
```

---

## 🚀 Panduan Replikasi Eksperimen

1. **Jalankan via Google Colab:**
   - Unggah berkas [`Studio_Proyek_3_NLP.ipynb`](notebooks/Studio_Proyek_3_NLP.ipynb) ke Google Colab.
   - Pastikan runtime disetel ke **GPU (T4 GPU)**.
2. **Mode Eksekusi:**
   - **`MODE = "smoke"`**: Melakukan verifikasi cepat alur kode menggunakan subset mini (1 epoch, 1 seed) untuk memastikan seluruh dependensi berfungsi normal tanpa error.
   - **`MODE = "full"`**: Menjalankan matriks eksperimen lengkap 27 run (3 model × 3 strategi × 3 seed), menghasilkan evaluasi statistik, dan menyimpan seluruh CSV serta gambar grafik secara otomatis ke direktori keluaran.

---

## 📚 Referensi

1. **SmSA & IndoNLU:** Wilie, B., dkk. (2020). *IndoNLU: Benchmark and Resources for Evaluating Indonesian Natural Language Understanding*. Proceedings of AACL-IJCNLP 2020.
2. **IndoBERT:** Koto, F., Rahimi, A., Lau, J. H., & Baldwin, T. (2020). *IndoLEM and IndoBERT: A Benchmark Dataset and Pre-trained Language Model for Indonesian NLP*. Proceedings of COLING 2020.
3. **mBERT:** Devlin, J., Chang, M. W., Lee, K., & Toutanova, K. (2019). *BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding*. Proceedings of NAACL-HLT 2019.
4. **DistilBERT:** Sanh, V., Debut, L., Chaumond, J., & Wolf, T. (2019). *DistilBERT, a distilled version of BERT: smaller, faster, cheaper and lighter*. NeurIPS EMC² Workshop.

---
*Proyek Studio Proyek 3 — Pembelajaran Mendalam (IF25-40401) | Teknik Informatika, Institut Teknologi Sumatera (ITERA).*
