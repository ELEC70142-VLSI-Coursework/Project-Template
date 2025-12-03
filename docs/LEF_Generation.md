Below is a cleaner, more structured Markdown rewrite of your guide:

---

# LEF Extraction from GDS

This guide describes how to generate a LEF file using the **Cadence Abstract** tool from either an existing library or a standalone GDSII file.

---

## 1. Launch Abstract

1. Start the PDK environment.
2. Navigate to the directory *above* the design library you want to convert.
3. Launch the tool:

   ```bash
   abstract
   ```

### Open the Library

* Go to **File → Library → Open** and select the library.

### If Only a GDSII File Is Available

* Import the GDSII file via **File → Import → Stream (GDSII)**.

### Ensure the Cell Is Defined as a Block

If the cell of interest is not defined as a *Block*:

1. Select the cell in the left panel.
2. Go to **Cells → Move → Block**.

---

## 2. Pin Definition

1. Open the pin configuration window via **Flow → Pin**.
2. Fill out the required fields.

### Mapping Text Labels to Pins

Specify:

* The layer containing text labels.
* The metal layer(s) where pins exist.
* Optionally, the purpose (e.g., `pin`, `drawing`).

**Format:**

```
(textLayer (metalLayer purpose) ...)
```

### Examples

Labels on metal layers 3, 2, and 5, with pins of type *pin*:

```
(M3 (M3 pin))
(M2 (M2 pin))
(M5 (M5 pin))
```

Labels on a text layer with pins on M1 drawing layer:

```
(text (M1 drawing))
```

![Pin Extraction Example](./imgs/Abstract_Pin.PNG)


### Power/Ground and Clock/Output Names

* Power and ground nets are usually recognized automatically by the default regex.
* If not, specify their names explicitly in the corresponding fields.
* Define the clock name and output pin names as well.

Run the extraction and check the **Log** to ensure all pins were found correctly.

---

## 3. Extract Traces

This step identifies connectivity between shapes and terminals.

1. Go to **Flow → Extract**.
2. Default settings generally work for simple designs.
3. Click **Run**, then review the log for potential issues.

---

## 4. Abstract Generation

1. Go to **Flow → Abstract**.
3. Click **Run**.

You may encounter warnings about power rails—these can typically be ignored for non–standard-cell designs.

---

## 5. Export the LEF

Export the final LEF file via:

**File → Export → LEF**

Save the resulting `.lef` file.

---

## Additional Resources

* [https://www.youtube.com/watch?v=c0IgLac4guI](https://www.youtube.com/watch?v=c0IgLac4guI)
* [https://web.cecs.pdx.edu/~daasch/course/cadence/tutorials/Tutorial1.pdf](https://web.cecs.pdx.edu/~daasch/course/cadence/tutorials/Tutorial1.pdf)
* [https://www.eecs.umich.edu/courses/eecs427/f08/tutorial4.pdf](https://www.eecs.umich.edu/courses/eecs427/f08/tutorial4.pdf)

---
