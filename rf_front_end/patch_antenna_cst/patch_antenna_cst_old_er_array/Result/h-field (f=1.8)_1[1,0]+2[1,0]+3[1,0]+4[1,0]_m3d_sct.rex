<?xml version="1.0" encoding="UTF-8"?>
<MetaResultFile version="20211011" creator="Solver HFTD - Field 3DFD Monitor Combine Result">
  <MetaGeometryFile filename="model.gex" lod="1"/>
  <SimulationProperties fieldname="surface current (f=1.8) [1[1,0]+2[1,0]+3[1,0]+4[1,0]]" frequency="1.8" encoded_unit="&amp;U:A^1.:m^-1" quantity="h-field" fieldtype="Surface current" fieldscaling="PEAK" dB_Amplitude="20"/>
  <ResultDataType vector="1" complex="1" timedomain="0" frequencymap="0"/>
  <SimulationDomain min="-246.389252 -60.4792442 -31.4442463" max="61.9792442 60.4792442 39.1090469"/>
  <PlotSettings Plot="2" ignore_symmetry="0" deformation="0" enforce_culling="0" integer_values="0" combine="CombineNone" default_arrow_type="ARROWS" default_scaling="NONE"/>
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
      <Result treepath="2D/3D Results\Surface Current\surface current (f=1.8) [1]" rexname="h-field (f=1.8)_1,1_m3d_sct.rex"/>
    </SharedDataWith>
    <Frame index="0">
      <FieldResultFile filename="h-field (f=1.8)_1[1,0]+2[1,0]+3[1,0]+4[1,0].m3d" type="m3d"/>
    </Frame>
  </ResultGroups>
</MetaResultFile>
