## uMCGA (universal Monte Carlo Genetic Algorithm)

Solve optimization problems with the MCGA algorithm [1]. The present algorithm is desribed in [2]. 
uMCGA allows for optimization of problems where parameters need to be fit to multiple datasets. 
The code is originally developed for deriving secondary organic aerosol properties 
(such as composition and diffusion coefficients of different organic compounds in the particle phase)
from experimental data where evaporation of the particles was measured. Currently only MATLAB implementation is available.

## Usage

results = umcga(problem)

### Input

* **problem**: Structure that describes the optimization problem. Needs to include fields.

    - **populationSize**: Size of the population in the genetic algorithm part.
    - **populationSizeExtra**: Size of the population in the Monte Carlo part.
    - **NElite**: Number of elite candidates that are always moved to the next generation.
    - **Ngen**: Number of generations. The MC part is the first generation hence there will be (Ngen-1) generations in the GA part.
    - **Nrun**: Number of independent optimization runs.
    - **Ndataset**: Number of data sets that are used in the optimization.
    - **mutationProbability**: The probability value between 0-1 for the mutation to happen in the genetic algorithm. 
When mutation happens the free parameters of a candidate are drawn again randomly for their set intervals 
(see fitparams structure description below for the free parameter definition)
    - **models**: Name of the file (string) that needs to be called to run each model. The models are specified as sub structres as

    ```
    models.model1: name of first model
    models.model2: name of the second model
    models.modelNdataset: name of the Nth model.
    ```

    - **params**: Parameters for the numerical models that describe the system which produces the measured values. These are specified as

```
params.set1: parameters for the first model
params.set2: parameteters for the second model
params.setNdataset: parameters for the Nth model.

```

    - **data**:   Data sets against which the output of the models is compared
the first data set is compared against the output of the first
model, the second data set against the output of the second
model and so on. The data sets are speciefied as


```
data.data1: first data set
data.data2: second data set
data.dataNdataset: Nth data set.
```

    - **gofFunction**: Name of the goodness-of-fit function. The gof function
needs to take two arguments as gofFunction(problem,member)
where problem is the problem structure defined as the
input to the umcga and member is a structure containing 
the output of each model in a candidate solution. 
The fields in a 'member' are


```
member.params: parameters of the candidate in the same order as in the problem.params
member.simulations: output of the models in sub structers
member.simulations.simulation1: output of the first model
member.simulations.simulation2: output of the second model
member.simulations.simulationN: output of the Nth model.
```

The gofFunction needs to return a single value which is the goodness-of-fit. **NB! The goal of the algorithm is to minimize this function.**

    - **badFitness**: Goodness-of-fit value assigned to a candidate whose model 
output can not be calculated. This should be a high number
wrt. the typical fitness values given by the gofFunction.
                 
    - **penaltyFunction**: (optional) Function that takes in the 
problem.params structure and returns both a boolean
value and the same params structure in this order. If
the boolean value is 1 the candidate is not accepted
and the fitted parameters are drawn again. If the
boolean value is 0 the parameters of the candidate are
accepted. This function can be used to restrict some
parts of the free parameter space.

    - **problem.params.set1.includeToPenaltyFunction**: (optional) cell of strings containing the
names of the parameters that are passed also 
to the penalty function in addition to the fitparams (see below). Note that this field needs to be placed in the first set of the params field.

    - **parallel**: Boolean value whether or not the candidate creation is parallelized

    - **fitparams**: This structure marks which of the parameters in the params
structure are marked as free parameters and whose values 
the MCGA algorithm tries to change such that the model 
output(s) would match the data sets. Free parameters are
defined as substructures like
fitparams.paramName1 = name of the first free parameter.
Each new fitparam needs to have fields

```
paramName1.min: the minimum value the parameter can have
paramName1.max: the maximum value the parameter can have
paramName1.log: Boolean value. If 0 the parameter values are drawn from a uniform distribution if 1 the values are drawn from log-uniform distribution
paramName1.normalize: Boolean value. If 1 the values in this free parameter are normalized to unity
```

### Output
* **results**: Structure containing results of the optimization. Fields are
    - **problem**: The input problem structure.
    - **bestMembers.runN**: The best fit candidate in the Nth run each runNincludes fields.
        - **params**: The params structure from the problem structure and the values for the free parameters that best fit the data.
        - **simulations**: Model outputs in sub structers.
```
simulations.simulationN: output of the Nth model.
```
       - **fitness**: goodness-of-fit value for this best-fit candidate.

    - **bestSolutions.runN.generationN**: The best-fit candidate in the Nth run after the Nth generation had been created.

    - **fitnesses**: all the goodness-of-fit function values the dimensions are Nrun x Ngen x NPop

## Including constraints
See problem.penaltyFunction and problem.includeToPenaltyFunction structre definitions above. See also fitTotestData2.m and penalty2.m in examples/FallingSphere

## Did you detect any bugs / errors?

Please submit any bugs / errors encountered to Olli-Pekka Tikkanen (olli-pekka.tikkanen (at) helsinki dot fi) or start an issue here on Github.

## References
[1] Berkemeier, Thomas, et al. "Monte Carlo genetic algorithm (MCGA) for model analysis of multiphase chemical kinetics to determine transport and reaction rate coefficients using multiple experimental data sets." Atmospheric Chemistry and Physics 17.12 (2017): 8021 -- 8029. [https://doi.org/10.5194/acp-17-8021-2017](https://doi.org/10.5194/acp-17-8021-2017)

[2] Tikkanen, Olli-Pekka, et al., "Optimization of process models for determining volatility distribution and viscosity of organic aerosols from isothermal particle evaporation data" Atmospheric Chemistry and Physics 19.14 (2019): 9333 -- 9350. [https://doi.org/10.5194/acp-19-9333-2019](https://doi.org/10.5194/acp-19-9333-2019)

