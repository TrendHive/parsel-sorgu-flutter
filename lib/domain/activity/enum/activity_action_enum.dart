/// What a member did to a record.
///
/// [queried] is a parcel fetched from the registry for the first time;
/// [refreshed] is one fetched again with the Refresh button. [created], [updated] and
/// [deleted] are a person or a drawing.
enum ActivityActionEnum { queried, refreshed, created, updated, deleted }
