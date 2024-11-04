<?xml version="1.0" encoding="UTF-8"?>
<MetaResultFile version="20211011" creator="Solver HFTD - Field 3DFD Monitor Combine Result">
  <MetaGeometryFile filename="model.gex" lod="1"/>
  <SimulationProperties fieldname="e-field (f=1.8) [1[1,60]+2[1,90]+3[1,120]+4[1,150]]" frequency="1.8" encoded_unit="&amp;U:V^1.:m^-1" quantity="e-field" fieldtype="E-Field" fieldscaling="PEAK" dB_Amplitude="20"/>
  <ResultDataType vector="1" complex="1" timedomain="0" frequencymap="0"/>
  <SimulationDomain min="-246.389252 -60.4792442 -31.4442463" max="61.9792442 60.4792442 39.1090469"/>
  <PlotSettings Plot="4" ignore_symmetry="0" deformation="0" enforce_culling="0" integer_values="0" combine="CombineNone" default_arrow_type="ARROWS" default_scaling="NONE"/>
  <Source type="SOLVER"/>
  <SpecialMaterials>
    <Background type="NORMAL"/>
    <Material name="Copper (annealed)" type="FIELDFREE"/>
    <Material name="PEC" type="FIELDFREE"/>
  </SpecialMaterials>
  <AuxGeometryFile/>
  <AuxResultFile/>
  <FieldFreeNodes/>
  <SurfaceFieldCoefficients/>
  <UnitCell/>
  <SubVolume/>
  <Units/>
  <ProjectUnits/>
  <TimeSampling/>
  <LocalAxes/>
  <MeshViewSettings/>
  <ResultGroups num_steps="1" transformation="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1" process_mesh_group="0">
    <SharedDataWith>
      <Result treepath="" rexname=""/>
    </SharedDataWith>
    <Frame index="0">
      <FieldResultFile filename="e-field (f=1.8)_1[1,60]+2[1,90]+3[1,120]+4[1,150].m3d" type="m3d"/>
    </Frame>
  </ResultGroups>
</MetaResultFile>
