import pandas as pd
from math import pi

# Load the file
input_file = "Patch1_Spherical FieldsGain_EH_EV_ETheta_EPhi_ETotal.txt"
output_file = "patch1_converted_244GHz.txt"

# Read the file and handle potential errors
try:
    df = pd.read_csv(input_file, delim_whitespace=True, engine='python')
except Exception as e:
    print(f"Error reading the file: {e}")
    exit()

# Verify total rows loaded
print(f"Total rows in input file: {len(df)}")

# Clean and standardize column names
df.columns = df.columns.str.strip()  # Remove extra spaces
df.columns = df.columns.str.replace('.', '', regex=False)  # Remove dots
print("Columns found in the file:", df.columns)

# Filter for 2.44 GHz frequency
try:
    frequency = df['Frequency']
    df = df[df['Frequency'] == 2440000000]  # Frequency is in Hz
    df["Azimuth"] = 180*df['Azimuth']/pi
    df["Elevation"] = 180*df['Elevation']/pi
    
    df['Theta'] = df['Azimuth']
    df['Phi'] = (df['Elevation']+180) % 360

    keep_cols = ['Phi', 'Theta', 'EThetaRealpart', 'EThetaImaginarypart', 'EPhiRealpart', 'EPhiImaginarypart']
    df.drop(df.columns.difference(keep_cols), axis=1, inplace=True)
    for az in df["Phi"].unique():
        append_df = pd.DataFrame([[az, 180, 0, 0, 0, 0]], columns=keep_cols)
        df = pd.concat([append_df, df], ignore_index=True)
    # sort the df
    df.sort_values(by=["Phi", "Theta"], inplace=True)
    print(f"Total rows at 2.44 GHz: {len(df)}")
except KeyError as e:
    print(f"Column {e} not found. Check your input file for exact column names.")
    exit()

# Map columns to variables
try:
    azimuth   = df['Phi']
    elevation = df['Theta']
    re_etheta = df['EThetaRealpart']
    im_etheta = df['EThetaImaginarypart']
    re_ephi = df['EPhiRealpart']
    im_ephi = df['EPhiImaginarypart']
    tot_phi = len(azimuth.unique())
    tot_theta = len(elevation.unique())
except KeyError as e:
    print(f"Column {e} not found. Check your input file for exact column names.")
    exit()

# Write the reformatted file
try:
    with open(output_file, 'w') as f:
        # Write header
        f.write("// CST Farfield Source File\n\n")
        f.write("// Version:\n3.0\n\n")
        f.write("// Data Type\nFarfield\n\n")
        f.write("// #Frequencies\n1\n\n")
        f.write("//Position\n0.0 0.0 0.0\n\n")
        f.write("//z-Axis\n0.0 0.0 1.0\n\n")
        f.write("//x-Axis\n1.0 0.0 0.0\n\n")
        f.write("// Radiated Power [W,rms]\n4.293431e-001\n\n")
        f.write("// Accepted Power [W,rms]\n4.333676e-001\n\n")
        f.write("// Stimulated Power [W,rms]\n5.000000e-001\n\n")
        f.write("// Frequency[Hz]\n2440000000\n\n")
        f.write(f"// >> Total #phi samples, total #theta samples\n{tot_phi}   {tot_theta}\n\n")
        f.write("// >> Phi, Theta, Re(E_Theta), Im(E_Theta), Re(E_Phi), Im(E_Phi):\n")
        
        # Write data row by row
        for i in range(len(df)):
            try:
                f.write(f"{azimuth.iloc[i]:10.3f} {elevation.iloc[i]:10.3f} "
                        f"{re_etheta.iloc[i]:14.6e} {im_etheta.iloc[i]:14.6e} "
                        f"{re_ephi.iloc[i]:14.6e} {im_ephi.iloc[i]:14.6e}\n")
            except Exception as e:
                print(f"Error processing row {i}: {e}")
                continue
except Exception as e:
    print(f"Error writing to output file: {e}")
    exit()

print(f"File with 2.44 GHz data has been converted and saved as {output_file}")
