# E/I Balance and Network Dynamics Simulation

---

## Repository Structure

### Categories:
- **Simulation**: Performs parameter sweeps and saves `.mat` results.
- **Plotting**: Generates publication-quality visualizations.
- **Network Generation**: Constructs different graph types or modifies adjacency matrices.

---

## Simulation Scripts

### `RunSimulation.m`
- **Purpose**: Core simulation for a given network type, E/I ratio, noise level, and network size.
- **Inputs**:
  - `NetworkType` (`"BA"`, `"ER"`, `"WS"`)
  - `Alpha`: Noise strength
  - `AddNodeSize`: Number of node increments
  - `NumExp`: Number of trials per configuration
  - `EIRatio`: Fraction of excitatory neurons
- **Outputs**:
  - `MeanINT`: Average integration time vs network size
  - `r`: Correlation between INT and network size
- **Used by**: All `Run*.m` simulation sweep scripts

### `RunReproducibilityStudy.m`
- **Purpose**: Performs a sweep over network types and **noise levels** to assess reproducibility of INT-size correlations.
- **Output**: `Results_Reproducibility.mat`

### `RunReproducibilityStudy_EIBalance.m`
- **Purpose**: Performs a sweep over **E/I ratios** for each network type at a fixed noise level.
- **Output**: `Results_EIBalanceSweep.mat`

### `RunEdgeDensity_EISweep.m`
- **Purpose**: Performs a sweep over **edge density and E/I ratios** at fixed noise to evaluate their joint influence on INT.
- **Output**: `Results_EdgeDensity_EISweep.mat`

### `RunEdgeDensitySweep.m`
- **Purpose**: Performs a sweep over **edge density** only, at a fixed E/I ratio and noise level.
- **Output**: `Results_EdgeDensitySweep.mat`

---

## Plotting Scripts

### `GenerateEIFigures.m`
- **Purpose**: Generates heatmaps and line plots showing how INT-size correlations vary across E/I ratios.
- **Input**: `Results_EIBalanceSweep.mat`
- **Outputs**:  
  `Figure_EIBalance_Heatmap.png`,  
  `Figure_EIBalance_LinePlot.png`

### `Plot_EdgeDensity_EISweep.m`  
- **Purpose:**  Generates a grid of subplots showing how mean INT varies with edge density across different network types and E/I ratios. Each subplot includes a correlation coefficient.
- **Inputs:** `Results_EdgeDensity_EISweep.mat`
- **Outputs:**  `INT_vs_EdgeDensity_EIRatio_Subplots.png`


### `Plot_3x3_EdgeDensity_EIRatio.m`
- **Purpose**: Generates a 3×3 grid of surface plots and 2D slices to visualize how INT varies with edge density and E/I balance across network types.
- **Input**: `Results_EdgeDensity_EISweep.mat`
- **Output**: `INT_3x3_EdgeDensity_EIRatio.png`

### `Plot_3x3_Subplots_WithCorrelations.m`
- **Purpose**: Generates a 3×3 grid showing of surface plots and 2D slices for each network type across network sizes and E/I ratios.
- **Input**: `Results_EIBalanceSweep.mat`
- **Output**: `INT_3x3_Surface_And_Slices.png`

### `Plot_INT_vs_EIRatio.m`
- **Purpose**: Plots INT as a function of E/I ratio for a specified network size, comparing across network types.
- **Input**: `Results_EIBalanceSweep.mat`
- **Output**: `INT_vs_EIRatio_Size[SIZE].png`

### `Plot_NodeCount_EIRatioSweep.m`
- **Purpose**: Generates a grid of subplots showing how INT scales with network size across different E/I ratios and network types.
- **Input**: `Results_EIBalanceSweep.mat`
- **Output**: `INT_vs_NodeCount_EIRatioSweep_Subplots_Filtered_Compact.png`

---

## Network Generation Functions

### `BAmodel.m`
- **Purpose**: Generates a Barabási–Albert scale-free network using preferential attachment.
- **Inputs**:  
  `N0` (initial fully connected nodes),  
  `NumAddNode` (nodes to add),  
  `M` (edges per new node)
- **Output**: Adjacency matrix `A`

### `ERmodel.m`
- **Purpose**: Generates an Erdős–Rényi random graph.
- **Inputs**:  
  `n` (number of nodes),  
  `p` (edge probability)
- **Output**: Symmetric adjacency matrix `A`

### `WSmodel.m`
- **Purpose**: Generates a Watts–Strogatz small-world network.
- **Inputs**:  
  `n` (number of nodes),  
  `k` (neighbors per node),  
  `beta` (rewiring probability)
- **Output**: Adjacency matrix `A`

### `AddEIBalanceByNode.m`
- **Purpose**: Assigns each node as excitatory or inhibitory and modifies outgoing edge signs to match.
- **Inputs**:  
  `A` (adjacency matrix),  
  `EIRatio` (fraction of excitatory neurons)
- **Output**: Signed adjacency matrix `A_signed`

### Edge Density Note

Edge density is altered differently depending on the network model:

- **BA (Barabási–Albert):** Controlled by `M` – the number of edges each new node adds during attachment.
- **ER (Erdős–Rényi):** Controlled by `p` – the probability of forming an edge between any two nodes.
- **WS (Watts–Strogatz):** Controlled by `k` – the number of nearest neighbors each node is initially connected to.

---

## Dynamics and Analysis

### `SinOscillatorWithNoise01.m`
- **Purpose**: Defines the oscillator dynamics with coupling and noise, following Kuramoto-like model.
- **Inputs**:  
  `x`, `A`, `epsilon`, `~`, `Omega`, `Noise`
- **Output**: Derivative `dxdt`

### `AutoCorrFactor_tw01.m`
- **Purpose**: Computes the INT from the autocorrelation
- **Inputs**:  
  `Series` (signal),  
  `TimeResolution` (e.g., 0.01)
- **Outputs**:  
  `STS`, `ACF`, `Lags`, `bounds`

### `manual_corr.m`
- **Purpose**: Computes the Pearson correlation coefficient manually.
- **Inputs**:  
  Vectors `x` and `y`
- **Output**: Scalar `r`
