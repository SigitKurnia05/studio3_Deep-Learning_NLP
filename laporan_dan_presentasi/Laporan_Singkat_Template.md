# LAPORAN SINGKAT — STUDIO PROYEK 3
## Fine-Tuning Transformer Pretrained untuk Klasifikasi Sentimen Bahasa Indonesia (SmSA)

**Mata Kuliah:** Pembelajaran Mendalam (IF25-40401)
**Kelompok:** [X] — [Nama Anggota 1] ([NIM 1]), [Nama Anggota 2] ([NIM 2])
**Tanggal:** [tanggal presentasi]
**Tautan Notebook:** [URL Colab/Kaggle]

> **CARA PAKAI TEMPLATE INI**
> Semua tanda `[...]` dan `<...>` **wajib diisi dari hasil run kelompok sendiri** (`rekap_agregat_smsa.csv`).
> Jangan menyalin angka contoh dari dokumen mana pun. Angka yang bukan dari run sendiri = temuan palsu.
> Target panjang: **3–4 halaman**. Struktur halaman mengikuti Bab 9 panduan.md.

---

## HALAMAN 1 — Pendahuluan, Desain Penelitian, & Hipotesis

### 1.1 Latar Belakang
Analisis sentimen teks Bahasa Indonesia dipakai luas di industri (penyortiran ulasan e-commerce,
pemantauan reputasi merek, prioritisasi keluhan pelanggan). Persoalannya, model paling akurat belum
tentu yang paling layak pakai: ada trade-off antara akurasi dan biaya komputasi (waktu latih, latensi
inferensi, memori). Laporan ini mengukur trade-off tersebut secara terkendali.

### 1.2 Rumusan Masalah
1. Backbone mana yang paling unggul untuk SmSA, dan apakah keunggulannya melampaui variasi acak antar-seed?
2. Seberapa jauh strategi pembekuan lapisan tertinggal dari full fine-tuning, dan apakah penghematannya sepadan?
3. Konfigurasi mana yang paling direkomendasikan untuk skenario dunia nyata?

### 1.3 Matriks Eksperimen
<Salin tabel 27 run dari Bab 4.1 / sel Rancangan notebook. Sebutkan jumlah run yang benar-benar selesai.>

| ID | Backbone | Strategi | Seed |
|:---:|:---|:---|:---:|
| E1–E3 | `indobenchmark/indobert-base-p1` | full / partial / probing | 42, 123, 2024 |
| E4–E6 | `bert-base-multilingual-cased` | full / partial / probing | 42, 123, 2024 |
| E7–E9 | `distilbert-base-multilingual-cased` | full / partial / probing | 42, 123, 2024 |

**Jumlah run selesai:** [n]/27 · **Perangkat:** [GPU T4 / lainnya] · **Tanggal eksekusi:** [tanggal]

### 1.4 Variabel Terkendali
| Variabel | Nilai |
|:---|:---|
| `max_length` | [128] |
| `batch_size` | [32] |
| `num_epochs` | [4] |
| Learning rate (full / partial / probing) | [3e-5 / 3e-5 / 1e-3] |
| Gradient clipping | [1.0] |
| Seed | [42, 123, 2024] |
| Himpunan evaluasi | [validasi resmi SmSA, n=1260] |

### 1.5 Hipotesis
- **H1** — [tulis ulang H1 dari Bab 4.3]
- **H2** — [tulis ulang H2]
- **H3** — [tulis ulang H3]

---

## HALAMAN 2 — Metodologi & Praprocessing Data

### 2.1 Dataset
SmSA (IndoNLU, Wilie dkk., 2020), 3 kelas: `negative`, `neutral`, `positive`.
Pembagian resmi: train [11000] baris, validasi [1260] baris. Label data uji resmi **tidak** dipakai;
evaluasi memakai himpunan validasi resmi.

### 2.2 Protokol Pembersihan Data
| Tahap | Jumlah Terdampak | Catatan |
|:---|:---:|:---|
| Hapus duplikat teks persis | [67] | `drop_duplicates(subset='text')` |
| Hapus teks berlabel konfliktual | [0] | pada SmSA tidak ditemukan label bertentangan |
| Hapus kebocoran validasi di data latih | [16] | irisan teks train ∩ valid |
| **Hasil akhir train** | **[10919]** | dari [11000] baris mentah |

Distribusi kelas setelah pembersihan: positive [58,4%], negative [31,2%], neutral [10,4%].
Karena `neutral` minoritas, metrik utama adalah **Macro F1**.

> Isi angka pada tabel di atas dari output SEL 4 notebook kelompok sendiri. Angka di atas adalah
> hasil pengukuran satu kali dan **wajib diverifikasi ulang** saat run.

### 2.3 Strategi Fine-Tuning dan Aturan Pembekuan
| Strategi | Parameter Beku | Parameter Dilatih | Learning Rate |
|:---|:---|:---|:---|
| Full Fine-Tuning | tidak ada | 100% | [3e-5] |
| Partial Freezing | embedding + 6 layer awal (BERT) / 3 layer awal (DistilBERT) | [x]% | [3e-5] |
| Linear Probing | seluruh backbone (embedding + semua layer encoder) | [x]% | [1e-3] |

Isi kolom persentase dari output `atur_strategi_fine_tuning()` (mis. `Param Total: ... | Trainable: ...`).
Urutan yang harus terlihat: **probing < partial < full**.

### 2.4 Setup Reproduksibilitas
`set_seed()` mengunci seed Python Random, NumPy, dan PyTorch (`torch.manual_seed`, `torch.cuda.manual_seed_all`).
`cudnn.deterministic = True`, `cudnn.benchmark = False`. Semua run memakai protokol identik kecuali
faktor yang sedang diuji.

---

## HALAMAN 3 — Hasil Eksperimen & Analisis Komparatif

### 3.1 Tabel Utama: Rekap Agregat (Mean ± Std, n = 3 seed)
<Sisipkan isi `rekap_agregat_smsa.csv`. Format angka: 4 desimal.>

| Backbone | Strategi | Akurasi | Macro F1 | Waktu Latih (s) | Latensi (ms/kalimat) | Memori Puncak (MB) | Param Dilatih |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| indobert | full | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] |
| indobert | partial | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] |
| indobert | probing | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] |
| mbert | full | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] |
| mbert | partial | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] |
| mbert | probing | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] |
| distilmbert | full | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] |
| distilmbert | partial | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] |
| distilmbert | probing | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] ± [ ] | [ ] |

Catatan: latensi hanya boleh dibandingkan antar run **dalam sesi yang sama**.

### 3.2 Gambar
<Sisipkan `grafik_hasil_evaluasi.png` (4 panel: F1 macro, waktu latih, trade-off F1 vs latensi, memori puncak).>

### 3.3 Analisis Efisiensi
<Bahas: backbone mana termahal secara komputasi, berapa penghematan partial/probing relatif full,
apakah penghematan itu sebanding dengan penurunan F1. Rujuk angka tabel 3.1.>

---

## HALAMAN 4 — Pembahasan Pertanyaan Riset, Evaluasi Hipotesis, & Rekomendasi

### 4.1 Jawaban Pertanyaan Riset Wajib

**PR1 — Backbone mana yang paling unggul, dan apakah keunggulannya lebih besar daripada variasi acak antar-seed?**
<Cara menjawab: tulis F1 macro tiap backbone (mean ± std). Bandingkan selisih mean antar-backbone
terhadap std antar-seed-nya. Simpulkan secara eksplisit: selisih > std → keunggulan bukan kebetulan seed;
selisih ≈ std → belum bisa disimpulkan. Rujuk Bab 8 kerangka PR1.>

**PR2 — Seberapa jauh partial freezing dan linear probing tertinggal dari full fine-tuning, dan apakah penghematannya sepadan?**
<Cara menjawab: Δ F1 tiap strategi vs full, plus Δ waktu latih / memori. Nyatakan pada backbone mana
kompromi itu layak dan pada backbone mana tidak.>

**PR3 — Konfigurasi mana yang paling direkomendasikan untuk skenario dunia nyata?**
<Cara menjawab: petakan 3 skenario (server/akurasi tertinggi; pelatihan berulang anggaran terbatas;
real-time/latensi rendah) ke konfigurasi dengan bukti angka dari tabel 3.1.>

### 4.2 Status Hipotesis
| Hipotesis | Ringkas Klaim | Status | Bukti (angka dari run sendiri) |
|:---:|:---|:---:|:---|
| H1 | [ ] | Didukung / Ditolak / Didukung Bersyarat | [ ] |
| H2 | [ ] | [ ] | [ ] |
| H3 | [ ] | [ ] | [ ] |

### 4.3 Keterbatasan
<Contoh yang bisa diisi bila memang terjadi: jumlah seed hanya 3 sehingga uji signifikansi lemah;
latensi diukur pada GPU yang dipakai bersama; run terpotong kuota GPU sehingga jumlah seed tidak lengkap;
kelas neutral minoritas sehingga F1 kelas itu paling tidak stabil.>

### 4.4 Kesimpulan & Rekomendasi Praktis
<3 poin ringkas + 1 rekomendasi utama, semuanya bertumpu pada angka run sendiri.>

---

## Lampiran
- Tautan notebook + PDF hasil Run All (`STUDIO3_Kelompok[X]_[Nama1]_[Nama2].pdf`)
- `hasil_smsa_lengkap.csv` (log 27 run) dan `rekap_agregat_smsa.csv`
- Pembagian kerja anggota kelompok
