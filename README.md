# Rainmaker Sun Widget — Notre Soleil and Veille solaire

Two [Rainmeter](https://www.rainmeter.net/) widgets for Windows: **Notre Soleil** (“Our Sun”), based on the compact format of Notre planète, and **Veille solaire** (“Solar Watch”), based on the format of Veille cosmique. The panels are independent, share their data, and offer small, medium, and large sizes through the right-click menu. The ↻ button refreshes the data; updates also run automatically on first launch and every five minutes.

The widgets themselves are in French.

## Installation

1. Install Rainmeter if needed, then copy the `RainmakerSunWidget` folder into `Documents\Rainmeter\Skins`.
2. In **Manage Rainmeter**, refresh the skin list. Load `RainmakerSunWidget > SoleilCompact > Soleil.ini`, then `RainmakerSunWidget > VeilleSolaire > Veille.ini`.
3. Move the widgets to your preferred screen. Click ↻ to refresh immediately; the first update may take a few seconds.

An internet connection is required. If a measurement is unavailable or too old, it is displayed as dashes. Hover over a line to see its UTC timestamp and source status. The image may be delayed; its displayed date is the download time, not necessarily the time of observation.

## Sources and limitations

- [NASA SDO, AIA 304 Å image](https://sdo.gsfc.nasa.gov/data/): a colorized ultraviolet image, different from what the Sun looks like in visible light.
- [NOAA Space Weather Prediction Center](https://www.swpc.noaa.gov/content/data-access): GOES X-ray flux class; the class and time of the latest flare maximum reported by that feed; solar wind speed and Bz component near Earth; and the F10.7 radio flux. The latest maximum is a dated event and does not represent the current class.
- These indicators are neither forecasts nor local measurements. X-ray and solar wind measurements are hidden when they are more than 60 and 90 minutes old, respectively; the F10.7 flux is hidden after 72 hours.

`donnees.inc` contains an initial state that is regenerated on each refresh. The downloaded image `@Resources/Images/soleil.jpg` and temporary files are generated locally and excluded from the repository. Requests go directly to NOAA and NASA.

## Attribution and license

The compact panel uses the structure of **Planète compacte**, an adaptation of **Jord** by **crosseout**, licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/). This project is distributed under the same license. NASA and NOAA data and images remain subject to their providers' terms and are not included in the repository.
