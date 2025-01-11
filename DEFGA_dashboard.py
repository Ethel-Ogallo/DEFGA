"""
DEFGA : Development of Employment Figures by Gender in Austria 2013-2022
Date: 11-01-2025
Authors: Adana Mirzoyan , Ethel Ogallo
Dashboard visualizing the trend in employment figures by gender and region in Austria
"""
# load libraries
import streamlit as st
import pandas as pd
import altair as alt
import geopandas as gpd
import geojson
from pyproj import CRS
from owslib.wfs import WebFeatureService
import requests
import numpy
import plotly.express as px


# Fetch data from WFS 

# Specify the url for the backend.
url = "https://geoserver22s.zgis.at/geoserver/IPSDI_WT24/wfs?"

# Specify parameters (read data in json format).
params = dict(
    service="WFS",
    version="1.0.0",
    request="GetFeature",
    typeName="IPSDI_WT24:austria_employment_data_DEFGA",
    outputFormat="json",
)

# Fetch data from WFS using requests
r = requests.get(url, params=params)

# Create GeoDataFrame from geojson and set coordinate reference system
data = gpd.GeoDataFrame.from_features(geojson.loads(r.content), crs="EPSG:3857")


## Streamlit Layout
# Title
st.title("Development of Employment Figures by gender, Austria")

# Sidebar filters
st.sidebar.header("Filters")
selected_gender = st.sidebar.selectbox("Select Gender", data['gender'].unique())
selected_region = st.sidebar.multiselect("Select Region", data['region'].unique(), 
                                         default=data['region'].unique())
time_range = st.sidebar.slider("Select Year Range", 
                               int(data['year_date'].min().year), 
                               int(data['year_date'].max().year), 
                               (int(data['year_date'].min().year), 
                                int(data['year_date'].max().year)))

# Filter data
filtered_data = data[
    (data['gender'] == selected_gender) & 
    (data['region'].isin(selected_region)) & 
    (data['year_date'].dt.year.between(time_range[0], time_range[1]))
]

# Employment Trend by Gender Over Time
st.subheader("Employment Trend by Gender Over Time")
trend_chart = px.line(
    filtered_data, 
    x="year", 
    y="employment", 
    color="region", 
    title="Employment Trend"
)
st.plotly_chart(trend_chart, use_container_width=True)

# GeoPandas plot of employment by region
st.subheader("Map of Employment by Region")
ax = filtered_data.plot(column='num_employed', 
                        cmap='viridis', 
                        legend=True, 
                        legend_kwds={'label': "Number of Employed"})
st.pyplot(ax.get_figure()) 


