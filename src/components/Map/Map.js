import React, {Component} from 'react';
import {withScriptjs, withGoogleMap, GoogleMap, Polyline} from "react-google-maps"
import {Container, Row, Col} from 'reactstrap';


    class Map extends Component {
        constructor(props) {
            super(props);
            this.setMapCenter = this.setMapCenter.bind(this);
        }

        setMapCenter = () => {
            // pull out latitude longitude from wherever you're getting it from
            const { latitude, longitude } = this.props;
            this.setState({ latitude, longitude });
        };

        componentDidMount() {
            window.addEventListener('resize', this.setMapCenter);
        }
        componentWillUnmount() {
            window.removeEventListener('resize', this.setMapCenter);
        }

        render() {
            return (

                <Container fluid={true}>
                    <Row>
                        <Col xs={12}><GoogleMap style={{ margin: '20px'}}
                                                defaultZoom={3}
                                                defaultCenter={{lat: this.props.flights[0].originLat, lng: this.props.flights[0].originLng}}
                                                defaultOptions={{
                                                    mapTypeControl: false,
                                                    fullscreenControl: false,
                                                    streetViewControl: false
                                                }}
                                                ref={(map) => map && map.panTo({
                                                    lat: this.props.flights[0].originLat,
                                                    lng: this.props.flights[0].originLng
                                                })}
                        >
                            {
                                this.props.flights.map(function (flight, index) {
                                    return (
                                        <div key={flight.flightId}>
                                            <Polyline
                                                key={flight.flightId}
                                                path={[
                                                    {
                                                        lat: flight.originLat,
                                                        lng: flight.originLng
                                                    },
                                                    {
                                                        lat: flight.destLat,
                                                        lng: flight.destLng
                                                    }
                                                ]}
                                                options={{
                                                    strokeColor: 'red',
                                                    strokeWeight: 3,
                                                    strokeOpacity: 0.6,
                                                    geodesic: true
                                                }}
                                            />
                                        </div>
                                    )
                                })}
                        </GoogleMap></Col>
                    </Row>
                </Container>

            );
        }
    }




export default withScriptjs(withGoogleMap(Map));