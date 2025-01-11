"""
DEFGA : Development of Employment Figures by Gender in Austria 2013-2022
Date: 11-01-2025
Authors: Adana Mirzoyan , Ethel Ogallo
Dashboard visualizing the trend in employment figures by gender and region in Austria
"""
# load libraries
import streamlit as st
import pandas as pd
import geopandas as gpd
import geojson
from pyproj import CRS
from owslib.wfs import WebFeatureService
import requests

"""
Load the Web Feature Service published in geoserver
"""
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


