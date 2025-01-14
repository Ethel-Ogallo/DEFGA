# Streamlit Dashboard Layout

import streamlit as st
import pandas as pd
import altair as alt
import geopandas as gpd
import plotly.express as px
import geojson
from pyproj import CRS
from owslib.wfs import WebFeatureService
import requests

# Dashboard Title
st.set_page_config(page_title="Austria Employment Dashboard", layout="wide")
st.title("Austria Employment Dashboard")
st.markdown("Analyze gender employment trends across sectors and regions in Austria.")

# Sidebar for Filters
st.sidebar.header("Filters")
year_filter = st.sidebar.selectbox("Select Year", [2013, 2015, 2018])
gender_filter = st.sidebar.selectbox("Select Gender", ["Female", "Male", "Total"])
region_filter = st.sidebar.selectbox("Select Region", ["Urban", "Rural"])

# Data Loading
@st.cache_data
def load_data():
    # Specify the URL and parameters for WFS
    url = "https://geoserver22s.zgis.at/geoserver/IPSDI_WT24/wfs?"
    params = dict(
        service="WFS",
        version="1.0.0",
        request="GetFeature",
        typeName="IPSDI_WT24:austria_employment_data_DEFGA",
        outputFormat="json",
    )
    r = requests.get(url, params=params)
    data = gpd.GeoDataFrame.from_features(geojson.loads(r.content), crs="EPSG:3857")
    return data

data = load_data()

# Filter the data
filtered_data = data[
    (data["year"] == year_filter) &
    (data["gender"] == gender_filter) &
    (data["region"] == region_filter)
]

# Main Dashboard Layout
col1, col2 = st.columns([2, 1])

# Column 1: Map Visualization
with col1:
    st.subheader("Employment Distribution Map")
    st.map(filtered_data)

# Column 2: Summary Statistics
with col2:
    st.subheader("Summary Statistics")
    total_employment = filtered_data["num_employed"].sum()
    st.metric("Total Employment", total_employment)
    st.metric("Number of Records", len(filtered_data))

# Charts Section
st.subheader("Employment Trends")
chart_col1, chart_col2 = st.columns(2)

# Chart 1: Employment Over Time
with chart_col1:
    st.markdown("### Employment Over Time")
    line_chart = alt.Chart(filtered_data).mark_line().encode(
        x="year:O",
        y="num_employed:Q",
        color="gender:N"
    ).properties(
        width=400,
        height=300
    )
    st.altair_chart(line_chart)

# Chart 2: Employment by Region
with chart_col2:
    st.markdown("### Employment by Region")
    bar_chart = px.bar(
        filtered_data,
        x="region",
        y="num_employed",
        color="gender",
        barmode="group",
        title="Employment by Region"
    )
    st.plotly_chart(bar_chart, use_container_width=True)

# Raw Data Section
st.subheader("Raw Data")
st.write(filtered_data)
