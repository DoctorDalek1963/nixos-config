use chrono::{DateTime, Local, Months};

const SECS_PER_DAY_NORMAL_YEAR: f64 = 365. * 24. * 60. * 60.;
const SECS_PER_DAY_LEAP_YEAR: f64 = 366. * 24. * 60. * 60.;

fn main() {
    let mut args = ::std::env::args();

    _ = args.next().unwrap();
    let dob_string: String = args.next().unwrap();

    let date_of_birth = DateTime::parse_from_rfc3339(&dob_string).unwrap().to_utc();
    let now = Local::now().to_utc();

    let years = now.years_since(date_of_birth).unwrap();

    let now_minus_years = now.checked_sub_months(Months::new(years * 12)).unwrap();
    let delta = now_minus_years.signed_duration_since(date_of_birth);
    let seconds = delta.as_seconds_f64();

    let fractional_part = if now.date_naive().leap_year() {
        seconds / SECS_PER_DAY_LEAP_YEAR
    } else {
        seconds / SECS_PER_DAY_NORMAL_YEAR
    };

    let age = years as f64 + fractional_part;

    println!("{age:.7}");
}
